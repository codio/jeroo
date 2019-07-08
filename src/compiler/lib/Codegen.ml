open AST
open Position

type value =
  | FunV
  | JerooV of int
  | ObjV of (string, value) SymbolTable.t

type codegen_state = {
  code_queue : Bytecode.bytecode Queue.t;
  mutable num_jeroos : int;
  mutable pane : Pane.t
}

let raise_type_exception () =
  raise (Exceptions.CompileException {
      pos = {
        lnum = 0;
        cnum = 0;
      };
      pane = Pane.Main;
      exception_type = "internal error";
      message = "Type error, re-run the type checker";
    })

let relative_dir_of_expr meta_expr =
  match meta_expr.a with
  | AST.LeftExpr -> Bytecode.Left
  | AST.RightExpr -> Bytecode.Right
  | AST.HereExpr -> Bytecode.Here
  | AST.AheadExpr -> Bytecode.Ahead
  | _ -> raise_type_exception ()

let compass_dir_of_expr meta_expr =
  match meta_expr.a with
  | AST.NorthExpr -> Bytecode.North
  | AST.SouthExpr -> Bytecode.South
  | AST.EastExpr -> Bytecode.East
  | AST.WestExpr -> Bytecode.West
  | _ -> raise_type_exception ()

(* convert labels to memory locations *)
let remove_labels bytecode =
  (* create table from labels to memory locations *)
  let label_tbl = Hashtbl.create 30 in
  (* counter to keep track of the memory location *)
  let mem_loc = ref 0 in
  bytecode
  |> Seq.iter (function
      | Bytecode.LABEL (s, _, _) -> Hashtbl.add label_tbl s (!mem_loc)
      (* only increment the counter on non-labels *)
      (* since they get removed in the instruction set *)
      | _ -> incr mem_loc
    );

  (* swap out the jump to labels to jump to memory locations *)
  bytecode
  |> Seq.filter_map (function
      | Bytecode.JUMP_LBL (lbl, pane_num, line_num) ->
        Some (Bytecode.JUMP ((Hashtbl.find label_tbl lbl), pane_num, line_num))
      | Bytecode.BZ_LBL (lbl, pane_num, line_num) ->
        Some (Bytecode.BZ ((Hashtbl.find label_tbl lbl), pane_num, line_num))
      | Bytecode.LABEL _ -> None
      | _ as instruction -> Some (instruction)
    )

let rec gen_code_expr codegen_state symbol_table meta_expr =
  let expr = meta_expr.a in
  let line_num = meta_expr.pos.lnum in
  match expr with
  | AST.TrueExpr ->
    Queue.add (Bytecode.TRUE (codegen_state.pane, line_num)) codegen_state.code_queue
  | AST.FalseExpr ->
    Queue.add (Bytecode.FALSE (codegen_state.pane, line_num)) codegen_state.code_queue
  | AST.IntExpr _ | AST.IdExpr _
  | AST.NorthExpr | AST.SouthExpr | AST.EastExpr | AST.WestExpr
  | AST.AheadExpr | AST.LeftExpr | AST.RightExpr | AST.HereExpr -> ()
  | AST.BinOpExpr (e1, AST.And, e2) ->
    gen_code_expr codegen_state symbol_table e1;
    gen_code_expr codegen_state symbol_table e2;
    Queue.add (Bytecode.AND (codegen_state.pane, line_num)) codegen_state.code_queue
  | AST.BinOpExpr (e1, AST.Or, e2) ->
    gen_code_expr codegen_state symbol_table e1;
    gen_code_expr codegen_state symbol_table e2;
    Queue.add (Bytecode.OR (codegen_state.pane, line_num)) codegen_state.code_queue
  | AST.UnOpExpr (AST.Not, e) ->
    gen_code_expr codegen_state symbol_table e;
    Queue.add (Bytecode.NOT (codegen_state.pane, line_num)) codegen_state.code_queue
  | AST.BinOpExpr ({ a = AST.IdExpr(id); _ }, AST.Dot, e) ->
    let jeroo_tbl_opt = SymbolTable.find symbol_table "Jeroo" in
    let jerooV_opt = SymbolTable.find symbol_table id in
    begin match (jerooV_opt, jeroo_tbl_opt) with
      | (Some(JerooV(id_loc)), Some(ObjV(jeroo_tbl))) ->
        Queue.add (Bytecode.CSR (id_loc, codegen_state.pane, line_num)) codegen_state.code_queue;
        gen_code_expr codegen_state jeroo_tbl e
      | _ -> raise_type_exception ()
    end
  | AST.FxnAppExpr ({ a = AST.IdExpr(id); _ }, args) -> gen_code_fxn_app codegen_state symbol_table id args meta_expr.pos
  | _ -> raise_type_exception ()

and gen_code_fxn_app codegen_state symbol_table id args pos =
  match (id, args) with
  | ("hop", []) ->
    let instr = Bytecode.HOP (1, codegen_state.pane, pos.lnum) in
    Queue.add instr codegen_state.code_queue
  | ("hop", { a = AST.IntExpr(n); _ } :: []) ->
    let instr = Bytecode.HOP (n, codegen_state.pane, pos.lnum) in
    Queue.add instr codegen_state.code_queue
  | ("pick", []) ->
    let instr = Bytecode.PICK (codegen_state.pane, pos.lnum) in
    Queue.add instr codegen_state.code_queue
  | ("plant", []) ->
    let instr = Bytecode.PLANT (codegen_state.pane, pos.lnum) in
    Queue.add instr codegen_state.code_queue
  | ("toss", []) ->
    let instr = Bytecode.TOSS (codegen_state.pane, pos.lnum) in
    Queue.add instr codegen_state.code_queue
  | ("give", []) ->
    let instr = Bytecode.GIVE (Bytecode.Ahead, codegen_state.pane, pos.lnum) in
    Queue.add instr codegen_state.code_queue
  | ("give", meta_e :: []) ->
    let instr = Bytecode.GIVE ((relative_dir_of_expr meta_e), codegen_state.pane, pos.lnum) in
    Queue.add  instr codegen_state.code_queue
  | ("turn", meta_e :: []) ->
    let instr = Bytecode.TURN ((relative_dir_of_expr meta_e), codegen_state.pane, pos.lnum) in
    Queue.add instr codegen_state.code_queue
  | ("hasFlower", []) ->
    let instr = Bytecode.HASFLWR (codegen_state.pane, pos.lnum) in
    Queue.add instr codegen_state.code_queue
  | ("isJeroo", meta_e :: []) ->
    let instr = Bytecode.ISJEROO ((relative_dir_of_expr meta_e), codegen_state.pane, pos.lnum) in
    Queue.add instr codegen_state.code_queue
  | ("isFacing", meta_e :: []) ->
    let instr = Bytecode.FACING ((compass_dir_of_expr meta_e), codegen_state.pane, pos.lnum) in
    Queue.add instr codegen_state.code_queue
  | ("isFlower", meta_e :: []) ->
    let instr = Bytecode.ISFLWR ((relative_dir_of_expr meta_e), codegen_state.pane, pos.lnum) in
    Queue.add instr codegen_state.code_queue
  | ("isNet", meta_e :: []) ->
    let instr = Bytecode.ISNET ((relative_dir_of_expr meta_e), codegen_state.pane, pos.lnum) in
    Queue.add instr codegen_state.code_queue
  | ("isWater", meta_e :: []) ->
    let instr = Bytecode.ISWATER ((relative_dir_of_expr meta_e), codegen_state.pane, pos.lnum) in
    Queue.add instr codegen_state.code_queue
  | ("isClear", meta_e :: []) ->
    let relative_dir = relative_dir_of_expr meta_e in
    let instrs = [
      Bytecode.ISJEROO (relative_dir, codegen_state.pane, pos.lnum);
      Bytecode.ISWATER (relative_dir, codegen_state.pane, pos.lnum);
      Bytecode.ISNET (relative_dir, codegen_state.pane, pos.lnum);
      Bytecode.ISFLWR (relative_dir, codegen_state.pane, pos.lnum);
      Bytecode.OR (codegen_state.pane, pos.lnum);
      Bytecode.OR (codegen_state.pane, pos.lnum);
      Bytecode.OR (codegen_state.pane, pos.lnum);
      Bytecode.NOT (codegen_state.pane, pos.lnum)
    ] |> List.to_seq in
    Queue.add_seq codegen_state.code_queue instrs
  | _ when (SymbolTable.mem symbol_table id) ->
    (* calling a user-defined function *)
    Queue.add (Bytecode.CALLBK (codegen_state.pane, pos.lnum)) codegen_state.code_queue;
    Queue.add (Bytecode.JUMP_LBL (id, codegen_state.pane, pos.lnum)) codegen_state.code_queue
  | _ -> raise_type_exception ()

let gen_code_decl id_loc args pos =
  match args with
  | [] ->
    Bytecode.NEW (id_loc, 0, 0, 0, Bytecode.East, pos.lnum)
  | { a = AST.IntExpr(num_flowers); _ } :: [] ->
    Bytecode.NEW (id_loc, 0, 0, num_flowers, Bytecode.East, pos.lnum)
  | { a = AST.IntExpr(x); _ } :: { a = AST.IntExpr(y); _ } :: [] ->
    Bytecode.NEW (id_loc, x, y, 0, Bytecode.East, pos.lnum)
  | { a = AST.IntExpr(x); _ } :: { a = AST.IntExpr(y); _ } :: { a = AST.IntExpr(num_flowers); _ } :: [] ->
    Bytecode.NEW (id_loc, x, y, num_flowers, Bytecode.East, pos.lnum)
  | { a = AST.IntExpr(x); _ } :: { a = AST.IntExpr(y); _ } :: { a = AST.IntExpr(num_flowers); _ } :: direction :: [] ->
    Bytecode.NEW (id_loc, x, y, num_flowers, (compass_dir_of_expr direction), pos.lnum)
  | _ -> raise_type_exception ()

let rec gen_code_stmt codegen_state symbol_table stmt =
  match stmt with
  | AST.BlockStmt stmts -> gen_code_block_stmt codegen_state symbol_table stmts
  | AST.ExprStmt expr -> gen_code_expr_stmt codegen_state symbol_table expr
  | AST.DeclStmt (ty, id, meta_expr) -> gen_code_decl_stmt codegen_state symbol_table ty id meta_expr
  | AST.IfStmt { a = (e, stmt); pos } -> gen_code_if codegen_state symbol_table e stmt pos
  | AST.IfElseStmt { a = (e, s1, s2); pos } -> gen_code_if_else codegen_state symbol_table e s1 s2 pos
  | AST.WhileStmt { a = (e, s); pos } -> gen_code_while codegen_state symbol_table e s pos

and gen_code_decl_stmt codegen_state symbol_table ty id meta_expr =
  if (not (String.equal ty "Jeroo")) || (SymbolTable.mem symbol_table id)
  then raise_type_exception ()
  else begin
    let id_loc = codegen_state.num_jeroos in
    codegen_state.num_jeroos <- succ codegen_state.num_jeroos;
    SymbolTable.add symbol_table id (JerooV id_loc);
    let expr = meta_expr.a in
    match expr with
    | AST.UnOpExpr (AST.New, { a = AST.FxnAppExpr ({ a = AST.IdExpr(ctor); _ }, args); _ }) ->
      if not (String.equal ctor "Jeroo")
      then raise_type_exception ()
      else begin
        Queue.add (gen_code_decl id_loc args meta_expr.pos) codegen_state.code_queue;
        meta_expr.pos.lnum
      end
    | _ -> raise_type_exception ()
  end;

and gen_code_block_stmt codegen_state symbol_table stmts =
  (* fold_left will always return the line number of the last statement executed *)
  stmts
  |> List.fold_left (fun _ stmt -> gen_code_stmt codegen_state symbol_table stmt) 0

and gen_code_expr_stmt codegen_state symbol_table expr =
  begin match expr.a with
    | Some e -> gen_code_expr codegen_state symbol_table e
    | _ -> ()
  end;
  expr.pos.lnum

and gen_code_if codegen_state symbol_table e stmt pos =
  gen_code_expr codegen_state symbol_table e;
  let jmp_lbl = "if_lbl_" ^ (string_of_int (Queue.length codegen_state.code_queue)) in
  let jmp = (Bytecode.BZ_LBL (jmp_lbl, codegen_state.pane, pos.lnum)) in
  Queue.add jmp codegen_state.code_queue;

  let stmt_tbl = SymbolTable.add_level symbol_table in
  let end_lnum = gen_code_stmt codegen_state stmt_tbl stmt in

  Queue.add (Bytecode.LABEL (jmp_lbl, codegen_state.pane, end_lnum)) codegen_state.code_queue;
  end_lnum

and gen_code_if_else codegen_state symbol_table e s1 s2 pos =
  (* generate code for the condition *)
  gen_code_expr codegen_state symbol_table e;

  (* if the condition is false, jump to the else block, else execute the true block *)
  let else_lbl = "else_lbl_" ^ (string_of_int (Queue.length codegen_state.code_queue)) in
  let else_jmp = (Bytecode.BZ_LBL (else_lbl, codegen_state.pane, pos.lnum)) in
  Queue.add else_jmp codegen_state.code_queue;

  let parent_tbl = symbol_table in
  (* generate the code for the if-block *)
  let s1_tbl = SymbolTable.add_level parent_tbl in
  let true_end_lnum = gen_code_stmt codegen_state s1_tbl s1 in

  (* at the end of the true block, jump to the end of the if-else block *)
  let done_lbl = "done_lbl_" ^ (string_of_int (Queue.length codegen_state.code_queue)) in
  let done_jmp = (Bytecode.JUMP_LBL (done_lbl, codegen_state.pane, true_end_lnum)) in
  Queue.add done_jmp codegen_state.code_queue;
  Queue.add (Bytecode.LABEL (else_lbl, codegen_state.pane, true_end_lnum)) codegen_state.code_queue;

  (* generate the code for the else-block *)
  let s2_tbl = SymbolTable.add_level parent_tbl in
  let false_end_lnum = gen_code_stmt codegen_state s2_tbl s2 in

  Queue.add (Bytecode.LABEL (done_lbl, codegen_state.pane, false_end_lnum)) codegen_state.code_queue;
  false_end_lnum

and gen_code_while codegen_state symbol_table e s pos =
  let loop_lbl = "loop_lbl_" ^ (string_of_int (Queue.length codegen_state.code_queue)) in
  Queue.add (Bytecode.LABEL (loop_lbl, codegen_state.pane, pos.lnum)) codegen_state.code_queue;
  gen_code_expr codegen_state symbol_table e;
  let done_lbl = "done_lbl_" ^ (string_of_int (Queue.length codegen_state.code_queue)) in
  Queue.add (Bytecode.BZ_LBL (done_lbl, codegen_state.pane, e.pos.lnum)) codegen_state.code_queue;

  let stmt_tbl = SymbolTable.add_level symbol_table in
  let end_while_lnum = gen_code_stmt codegen_state stmt_tbl s in

  Queue.add (Bytecode.JUMP_LBL (loop_lbl, codegen_state.pane, end_while_lnum)) codegen_state.code_queue;
  Queue.add (Bytecode.LABEL (done_lbl, codegen_state.pane, end_while_lnum)) codegen_state.code_queue;
  end_while_lnum

let gen_code_fxn codegen_state symbol_table fxn =
  if SymbolTable.mem symbol_table fxn.id
  then raise_type_exception ()
  else begin
    SymbolTable.add symbol_table fxn.id FunV;
    Queue.add (Bytecode.LABEL (fxn.id, codegen_state.pane, fxn.start_lnum)) codegen_state.code_queue;
    let child_tbl = SymbolTable.add_level symbol_table in
    fxn.stmts
    |> List.iter (fun stmt -> ignore (gen_code_stmt codegen_state child_tbl stmt));
    Queue.add (Bytecode.RETR (codegen_state.pane, fxn.end_lnum)) codegen_state.code_queue;
  end

let codegen translation_unit =
  let codegen_state = {
    code_queue = Queue.create();
    num_jeroos = 0;
    pane = Pane.Extensions
  }
  in
  let main_tbl = SymbolTable.create () in
  let extension_tbl = SymbolTable.create () in
  (* at the start of execution, jump to main *)
  Queue.add (Bytecode.JUMP_LBL ("main", Pane.Main, translation_unit.main_fxn.start_lnum)) codegen_state.code_queue;

  (* generate the code for all of the extension methods *)
  SymbolTable.add main_tbl "Jeroo" (ObjV extension_tbl);
  translation_unit.extension_fxns
  |> List.iter (gen_code_fxn codegen_state extension_tbl);

  (* generate the code for the main function *)
  codegen_state.pane <- Pane.Main;
  gen_code_fxn codegen_state main_tbl translation_unit.main_fxn;
  let code_with_labels = Queue.to_seq codegen_state.code_queue in

  (* remove the labels *)
  let bytecode = remove_labels code_with_labels in
  (* create the jeroo mapping *)
  let jeroo_tbl = Hashtbl.create 10 in
  (SymbolTable.inverse_fold main_tbl () (fun a b _ -> match b with
       | JerooV id -> Hashtbl.add jeroo_tbl a id
       | _ -> ()
     ));
  (bytecode, jeroo_tbl)
