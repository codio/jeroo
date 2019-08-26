open AST
open Position

type value =
  | FunV
  | JerooV of int
  | ObjV of (string, value) SymbolTable.t

type state = {
  bytecode : Bytecode.bytecode Deque.t;
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

(* get the line number assiciated to the bytecode instruction *)
(* could be simplified if the bytecode instructions were stored as meta *)
let lnum_of_bytecode_instr = function
  | Bytecode.CSR (_, _, lnum)
  | Bytecode.JUMP_LBL (_, _, lnum)
  | Bytecode.JUMP (_, _, lnum)
  | Bytecode.BZ_LBL (_, _, lnum)
  | Bytecode.BZ (_, _, lnum)
  | Bytecode.LABEL (_, _, lnum)
  | Bytecode.NEW (_, _, _, _, _, lnum)
  | Bytecode.TURN (_, _, lnum)
  | Bytecode.HOP (_, _, lnum)
  | Bytecode.PICK (_, lnum)
  | Bytecode.TOSS (_, lnum)
  | Bytecode.PLANT (_, lnum)
  | Bytecode.GIVE (_, _, lnum)
  | Bytecode.TRUE (_, lnum)
  | Bytecode.FALSE (_, lnum)
  | Bytecode.HASFLWR (_, lnum)
  | Bytecode.ISNET (_, _, lnum)
  | Bytecode.ISWATER (_, _, lnum)
  | Bytecode.ISJEROO (_, _, lnum)
  | Bytecode.ISFLWR (_, _, lnum)
  | Bytecode.FACING (_, _, lnum)
  | Bytecode.NOT (_, lnum)
  | Bytecode.AND (_, lnum)
  | Bytecode.OR (_, lnum)
  | Bytecode.RETR (_, lnum)
  | Bytecode.CALLBK (_, lnum)
    -> lnum

(* convert labels to memory locations *)
let remove_labels bytecode =
  (* create table from labels to memory locations *)
  let label_tbl = Hashtbl.create 30 in
  (* counter to keep track of the memory location *)
  let mem_loc = ref 0 in
  bytecode
  |> List.iter (function
      | Bytecode.LABEL (s, _, _) -> Hashtbl.add label_tbl s (!mem_loc)
      (* only increment the counter on non-labels *)
      (* since they get removed in the instruction set *)
      | _ -> incr mem_loc
    );

  (* swap out the jump to labels to jump to memory locations *)
  bytecode
  |> List.filter_map (function
      | Bytecode.JUMP_LBL (lbl, pane_num, line_num) ->
        Some (Bytecode.JUMP ((Hashtbl.find label_tbl lbl), pane_num, line_num))
      | Bytecode.BZ_LBL (lbl, pane_num, line_num) ->
        Some (Bytecode.BZ ((Hashtbl.find label_tbl lbl), pane_num, line_num))
      | Bytecode.LABEL _ -> None
      | _ as instruction -> Some (instruction)
    )

let rec gen_code_expr state symbol_table meta_expr =
  let expr = meta_expr.a in
  let line_num = meta_expr.pos.lnum in
  match expr with
  | AST.TrueExpr ->
    Deque.insert_back (Bytecode.TRUE (state.pane, line_num)) state.bytecode
  | AST.FalseExpr ->
    Deque.insert_back (Bytecode.FALSE (state.pane, line_num)) state.bytecode
  | AST.IntExpr _ | AST.IdExpr _
  | AST.NorthExpr | AST.SouthExpr | AST.EastExpr | AST.WestExpr
  | AST.AheadExpr | AST.LeftExpr | AST.RightExpr | AST.HereExpr -> ()
  | AST.BinOpExpr (e1, (AST.And, _), e2) ->
    gen_code_expr state symbol_table e1;
    gen_code_expr state symbol_table e2;
    Deque.insert_back (Bytecode.AND (state.pane, line_num)) state.bytecode
  | AST.BinOpExpr (e1, (AST.Or, _), e2) ->
    gen_code_expr state symbol_table e1;
    gen_code_expr state symbol_table e2;
    Deque.insert_back (Bytecode.OR (state.pane, line_num)) state.bytecode
  | AST.UnOpExpr ((AST.Not, _), e) ->
    gen_code_expr state symbol_table e;
    Deque.insert_back (Bytecode.NOT (state.pane, line_num)) state.bytecode
  | AST.BinOpExpr ({ a = AST.IdExpr(id); _ }, (AST.Dot, _), e) ->
    let jeroo_tbl_opt = SymbolTable.find symbol_table "Jeroo" in
    let jerooV_opt = SymbolTable.find symbol_table id in
    begin match (jerooV_opt, jeroo_tbl_opt) with
      | (Some(JerooV(id_loc)), Some(ObjV(jeroo_tbl))) ->
        Deque.insert_back (Bytecode.CSR (id_loc, state.pane, line_num)) state.bytecode;
        gen_code_expr state jeroo_tbl e
      | _ -> raise_type_exception ()
    end
  | AST.FxnAppExpr ({ a = AST.IdExpr(id); _ }, args) -> gen_code_fxn_app state symbol_table id args meta_expr.pos
  | _ -> raise_type_exception ()

and gen_code_fxn_app state symbol_table id args pos =
  match (id, args) with
  | ("hop", []) ->
    let instr = Bytecode.HOP (1, state.pane, pos.lnum) in
    Deque.insert_back instr state.bytecode
  | ("hop", { a = AST.IntExpr(n); _ } :: []) ->
    let instr = Bytecode.HOP (n, state.pane, pos.lnum) in
    Deque.insert_back instr state.bytecode
  | ("pick", []) ->
    let instr = Bytecode.PICK (state.pane, pos.lnum) in
    Deque.insert_back instr state.bytecode
  | ("plant", []) ->
    let instr = Bytecode.PLANT (state.pane, pos.lnum) in
    Deque.insert_back instr state.bytecode
  | ("toss", []) ->
    let instr = Bytecode.TOSS (state.pane, pos.lnum) in
    Deque.insert_back instr state.bytecode
  | ("give", []) ->
    let instr = Bytecode.GIVE (Bytecode.Ahead, state.pane, pos.lnum) in
    Deque.insert_back instr state.bytecode
  | ("give", meta_e :: []) ->
    let instr = Bytecode.GIVE ((relative_dir_of_expr meta_e), state.pane, pos.lnum) in
    Deque.insert_back  instr state.bytecode
  | ("turn", meta_e :: []) ->
    let instr = Bytecode.TURN ((relative_dir_of_expr meta_e), state.pane, pos.lnum) in
    Deque.insert_back instr state.bytecode
  | ("hasFlower", []) ->
    let instr = Bytecode.HASFLWR (state.pane, pos.lnum) in
    Deque.insert_back instr state.bytecode
  | ("isJeroo", meta_e :: []) ->
    let instr = Bytecode.ISJEROO ((relative_dir_of_expr meta_e), state.pane, pos.lnum) in
    Deque.insert_back instr state.bytecode
  | ("isFacing", meta_e :: []) ->
    let instr = Bytecode.FACING ((compass_dir_of_expr meta_e), state.pane, pos.lnum) in
    Deque.insert_back instr state.bytecode
  | ("isFlower", meta_e :: []) ->
    let instr = Bytecode.ISFLWR ((relative_dir_of_expr meta_e), state.pane, pos.lnum) in
    Deque.insert_back instr state.bytecode
  | ("isNet", meta_e :: []) ->
    let instr = Bytecode.ISNET ((relative_dir_of_expr meta_e), state.pane, pos.lnum) in
    Deque.insert_back instr state.bytecode
  | ("isWater", meta_e :: []) ->
    let instr = Bytecode.ISWATER ((relative_dir_of_expr meta_e), state.pane, pos.lnum) in
    Deque.insert_back instr state.bytecode
  | ("isClear", meta_e :: []) ->
    let relative_dir = relative_dir_of_expr meta_e in
    [
      Bytecode.ISJEROO (relative_dir, state.pane, pos.lnum);
      Bytecode.ISWATER (relative_dir, state.pane, pos.lnum);
      Bytecode.ISNET (relative_dir, state.pane, pos.lnum);
      Bytecode.ISFLWR (relative_dir, state.pane, pos.lnum);
      Bytecode.OR (state.pane, pos.lnum);
      Bytecode.OR (state.pane, pos.lnum);
      Bytecode.OR (state.pane, pos.lnum);
      Bytecode.NOT (state.pane, pos.lnum)
    ]
    |> List.iter (fun instr -> Deque.insert_back instr state.bytecode)
  | _ when (SymbolTable.mem symbol_table id) ->
    (* calling a user-defined function *)
    Deque.insert_back (Bytecode.CALLBK (state.pane, pos.lnum)) state.bytecode;
    Deque.insert_back (Bytecode.JUMP_LBL (id, state.pane, pos.lnum)) state.bytecode
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
  | { a = AST.IntExpr(x); _ } :: { a = AST.IntExpr(y); _ } :: direction :: [] ->
    Bytecode.NEW (id_loc, x, y, 0, (compass_dir_of_expr direction), pos.lnum)
  | { a = AST.IntExpr(x); _ } :: { a = AST.IntExpr(y); _ } :: direction :: { a = AST.IntExpr(num_flowers); _ } :: [] ->
    Bytecode.NEW (id_loc, x, y, num_flowers, (compass_dir_of_expr direction), pos.lnum)
  | _ -> raise_type_exception ()

let rec gen_code_stmt state symbol_table stmt =
  match stmt with
  | AST.BlockStmt stmts -> gen_code_block_stmt state symbol_table stmts
  | AST.ExprStmt expr -> gen_code_expr_stmt state symbol_table expr
  | AST.DeclStmt (ty, id, meta_expr) -> gen_code_decl_stmt state symbol_table ty id meta_expr
  | AST.IfStmt { a = (e, stmt); pos } -> gen_code_if state symbol_table e stmt pos
  | AST.IfElseStmt { a = (e, s1, s2); pos } -> gen_code_if_else state symbol_table e s1 s2 pos
  | AST.WhileStmt { a = (e, s); pos } -> gen_code_while state symbol_table e s pos

and gen_code_decl_stmt state symbol_table ty id meta_expr =
  if (not (String.equal ty "Jeroo")) || (SymbolTable.mem symbol_table id)
  then raise_type_exception ()
  else
    let id_loc = state.num_jeroos in
    state.num_jeroos <- succ state.num_jeroos;
    SymbolTable.add symbol_table id (JerooV id_loc);
    let expr = meta_expr.a in
    match expr with
    | AST.UnOpExpr ((AST.New, _), { a = AST.FxnAppExpr ({ a = AST.IdExpr(ctor); _ }, args); _ }) ->
      if not (String.equal ctor "Jeroo")
      then raise_type_exception ()
      else Deque.insert_back (gen_code_decl id_loc args meta_expr.pos) state.bytecode;
    | _ -> raise_type_exception ()

and gen_code_block_stmt state symbol_table stmts =
  stmts
  |> List.iter (fun stmt -> gen_code_stmt state symbol_table stmt)

and gen_code_expr_stmt state symbol_table expr =
  match expr.a with
  | Some e -> gen_code_expr state symbol_table e
  | _ -> ()

and gen_code_if state symbol_table e stmt pos =
  gen_code_expr state symbol_table e;
  let jmp_lbl = "if_lbl_" ^ (string_of_int (Deque.length state.bytecode)) in
  let jmp = (Bytecode.BZ_LBL (jmp_lbl, state.pane, pos.lnum)) in
  Deque.insert_back jmp state.bytecode;

  let stmt_tbl = SymbolTable.add_level symbol_table in
  gen_code_stmt state stmt_tbl stmt;
  let end_lnum =
    Deque.get_back state.bytecode
    |> Option.map lnum_of_bytecode_instr
    |> Option.value ~default:0
  in

  Deque.insert_back (Bytecode.LABEL (jmp_lbl, state.pane, end_lnum)) state.bytecode

and gen_code_if_else state symbol_table e s1 s2 pos =
  (* generate code for the condition *)
  gen_code_expr state symbol_table e;

  (* if the condition is false, jump to the else block, else execute the true block *)
  let else_lbl = "else_lbl_" ^ (string_of_int (Deque.length state.bytecode)) in
  let else_jmp = (Bytecode.BZ_LBL (else_lbl, state.pane, pos.lnum)) in
  Deque.insert_back else_jmp state.bytecode;

  let parent_tbl = symbol_table in
  (* generate the code for the if-block *)
  let s1_tbl = SymbolTable.add_level parent_tbl in
  gen_code_stmt state s1_tbl s1;
  let true_end_lnum =
    Deque.get_back state.bytecode
    |> Option.map lnum_of_bytecode_instr
    |> Option.value ~default:0
  in
  (* at the end of the true block, jump to the end of the if-else block *)
  let done_lbl = "done_lbl_" ^ (string_of_int (Deque.length state.bytecode)) in
  let done_jmp = (Bytecode.JUMP_LBL (done_lbl, state.pane, true_end_lnum)) in
  Deque.insert_back done_jmp state.bytecode;
  Deque.insert_back (Bytecode.LABEL (else_lbl, state.pane, true_end_lnum)) state.bytecode;

  (* generate the code for the else-block *)
  let s2_tbl = SymbolTable.add_level parent_tbl in
  gen_code_stmt state s2_tbl s2;
  let false_end_lnum =
    Deque.get_back state.bytecode
    |> Option.map lnum_of_bytecode_instr
    |> Option.value ~default:0
  in

  Deque.insert_back (Bytecode.LABEL (done_lbl, state.pane, false_end_lnum)) state.bytecode

and gen_code_while state symbol_table e s pos =
  let loop_lbl = "loop_lbl_" ^ (string_of_int (Deque.length state.bytecode)) in
  Deque.insert_back (Bytecode.LABEL (loop_lbl, state.pane, pos.lnum)) state.bytecode;
  gen_code_expr state symbol_table e;
  let done_lbl = "done_lbl_" ^ (string_of_int (Deque.length state.bytecode)) in
  Deque.insert_back (Bytecode.BZ_LBL (done_lbl, state.pane, e.pos.lnum)) state.bytecode;

  let stmt_tbl = SymbolTable.add_level symbol_table in
  gen_code_stmt state stmt_tbl s;
  let end_while_lnum =
    Deque.get_back state.bytecode
    |> Option.map lnum_of_bytecode_instr
    |> Option.value ~default:0
  in

  Deque.insert_back (Bytecode.JUMP_LBL (loop_lbl, state.pane, end_while_lnum)) state.bytecode;
  Deque.insert_back (Bytecode.LABEL (done_lbl, state.pane, end_while_lnum)) state.bytecode

let gen_code_fxn state symbol_table (fxn : AST.fxn meta) =
  SymbolTable.add symbol_table fxn.a.id FunV;
  Deque.insert_back (Bytecode.LABEL (fxn.a.id, state.pane, fxn.pos.lnum)) state.bytecode;
  let child_tbl = SymbolTable.add_level symbol_table in
  fxn.a.stmts
  |> List.iter (fun stmt -> gen_code_stmt state child_tbl stmt);

  let last_stmt_lnum =
    (Option.bind
       (* get the last element in the stmt list *)
       (* if it is empty, just return None *)
       (List.nth_opt fxn.a.stmts (fxn.a.stmts |> List.length |> pred |> (max 0)))
       AST.stmt_pos)
    |> Option.map (fun pos -> pos.lnum)
    |> Option.value ~default:fxn.pos.lnum
  in
  Deque.insert_back (Bytecode.RETR (state.pane, last_stmt_lnum)) state.bytecode

let add_extension_fxns_to_env extension_fxns env =
  extension_fxns
  |> List.iter (fun fxn -> SymbolTable.add env fxn.a.id FunV)

let gen_code_extension_fxns extension_fxns env state =
  state.pane <- Pane.Extensions;
  extension_fxns
  |> List.iter (gen_code_fxn state env)

let gen_code_main_fxn main_fxn env state =
  state.pane <- Pane.Main;
  let fxn = {
    a = {
      id = "main";
      stmts = main_fxn.a.stmts;
    };
    pos = main_fxn.pos;
  }
  in
  gen_code_fxn state env fxn

let codegen translation_unit =
  let state = {
    bytecode = Deque.create ();
    num_jeroos = 0;
    pane = Pane.Extensions
  }
  in

  (* create the symbol tables *)
  let main_tbl = SymbolTable.create () in
  let extension_tbl = SymbolTable.create () in
  add_extension_fxns_to_env translation_unit.extension_fxns extension_tbl;
  SymbolTable.add main_tbl "Jeroo" (ObjV extension_tbl);

  (* at the start of execution, jump to main *)
  Deque.insert_back (Bytecode.JUMP_LBL ("main", Pane.Main, translation_unit.main_fxn.pos.lnum)) state.bytecode;

  (* generate the code *)
  gen_code_extension_fxns translation_unit.extension_fxns extension_tbl state;
  gen_code_main_fxn translation_unit.main_fxn main_tbl state;
  let code_with_labels = Deque.to_list state.bytecode in

  (* remove the labels *)
  let bytecode = remove_labels code_with_labels in

  (* create the jeroo mapping *)
  let jeroo_tbl = Hashtbl.create 10 in
  (SymbolTable.inverse_fold main_tbl () (fun a b _ -> match b with
       | JerooV id -> Hashtbl.add jeroo_tbl a id
       | _ -> ()
     ));
  (bytecode, jeroo_tbl)
