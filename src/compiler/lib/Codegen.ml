open AST

exception SemanticException of {
    lnum : int;
    message : string;
  }

let relative_dir_of_expr meta_expr =
  match meta_expr.a with
  | AST.LeftExpr -> Bytecode.Left
  | AST.RightExpr -> Bytecode.Right
  | AST.HereExpr -> Bytecode.Here
  | AST.AheadExpr -> Bytecode.Ahead
  | _ -> raise (SemanticException {
      lnum = meta_expr.lnum;
      message = "type error: expression must be LEFT, RIGHT, AHEAD, or HERE";
    })

let compass_dir_of_expr meta_expr =
  match meta_expr.a with
  | AST.NorthExpr -> Bytecode.North
  | AST.SouthExpr -> Bytecode.South
  | AST.EastExpr -> Bytecode.East
  | AST.WestExpr -> Bytecode.West
  | _ -> raise (SemanticException {
      lnum = meta_expr.lnum;
      message = "Invalid type, expression must be NORTH, SOUTH, EAST, or WEST";
    })

(* convert labels to memory locations *)
let remove_labels bytecode =
  (* create table from labels to memory locations *)
  let label_tbl = Hashtbl.create 30 in
  (* counter to keep track of the memory location *)
  let mem_loc = ref 0 in
  bytecode
  |> Seq.iter (fun intruction ->
      begin match intruction with
        | Bytecode.LABEL (s, _, _) -> Hashtbl.add label_tbl s (!mem_loc)
        | _ ->
          (* only increment the counter on non-labels *)
          (* since they get removed in the instruction set *)
          mem_loc := !mem_loc + 1
      end;
    );

  (* swap out the jump to labels to jump to memory locations *)
  bytecode
  |> Seq.filter_map (fun instruction -> match instruction with
      | Bytecode.JUMP_LBL (lbl, pane_num, line_num) ->
        Some (Bytecode.JUMP ((Hashtbl.find label_tbl lbl), pane_num, line_num))
      | Bytecode.BZ_LBL (lbl, pane_num, line_num) ->
        Some (Bytecode.BZ ((Hashtbl.find label_tbl lbl), pane_num, line_num))
      | Bytecode.LABEL _ -> None
      | _ -> Some (instruction)
    )

let codegen translation_unit =
  let fxn_tbl = Hashtbl.create 30 in
  let jeroo_tbl = Hashtbl.create 30 in
  let code_queue = Queue.create() in

  let rec gen_code_expr meta_expr pane_num =
    let expr = meta_expr.a in
    let line_num = meta_expr.lnum in
    match expr with
    | AST.TrueExpr ->
      Queue.add (Bytecode.TRUE (pane_num, line_num)) code_queue
    | AST.FalseExpr ->
      Queue.add (Bytecode.FALSE (pane_num, line_num)) code_queue
    | AST.BinOpExpr (e1, AST.And, e2) ->
      gen_code_expr e1 pane_num;
      gen_code_expr e2 pane_num;
      Queue.add (Bytecode.AND (pane_num, line_num)) code_queue
    | AST.BinOpExpr (e1, AST.Or, e2) ->
      gen_code_expr e1 pane_num;
      gen_code_expr e2 pane_num;
      Queue.add (Bytecode.OR (pane_num, line_num)) code_queue
    | AST.UnOpExpr (AST.Not, e) ->
      gen_code_expr e pane_num;
      Queue.add (Bytecode.NOT (pane_num, line_num)) code_queue
    | AST.BinOpExpr ({ a = AST.IdExpr(id); _ }, AST.Dot, e) ->
      let id_loc = Hashtbl.find jeroo_tbl id in
      Queue.add (Bytecode.CSR (id_loc, pane_num, line_num)) code_queue;
      gen_code_expr e pane_num
    | AST.FxnAppExpr ({ a = AST.IdExpr(id); _ }, args) ->
      begin match id with
        | "hop" -> begin match args with
            | [] ->
              let instr = Bytecode.HOP (1, pane_num, line_num) in
              Queue.add instr code_queue
            | { a = AST.IntExpr(n); _ } :: [] ->
              let instr = Bytecode.HOP (n, pane_num, line_num) in
              Queue.add instr code_queue
            | _ -> raise (SemanticException {
                lnum = line_num;
                message = "Invalid arguments, hop requires an integer as it's only parameter"
              })
          end
        | "pick" -> begin match args with
            | [] ->
              let instr = Bytecode.PICK (pane_num, line_num) in
              Queue.add instr code_queue
            | _ -> raise (SemanticException {
                lnum = line_num;
                message = "Invalid arguments, pick requires no arguments"
              })
          end
        | "plant" -> begin match args with
            | [] ->
              let instr = Bytecode.PLANT (pane_num, line_num) in
              Queue.add instr code_queue
            | _ -> raise (SemanticException {
                lnum = line_num;
                message = "Invalid arguments, plant requires no arguments"
              })
          end
        | "toss" -> begin match args with
            | [] ->
              let instr = Bytecode.TOSS (pane_num, line_num) in
              Queue.add instr code_queue
            | _ -> raise (SemanticException {
                lnum = line_num;
                message = "Invalid arguments, toss requires no arguments"
              })
          end
        | "give" -> begin match args with
            | [] ->
              let instr = Bytecode.GIVE (Bytecode.Ahead, pane_num, line_num) in
              Queue.add instr code_queue
            | meta_e :: [] ->
              let instr = Bytecode.GIVE ((relative_dir_of_expr meta_e), pane_num, line_num) in
              Queue.add  instr code_queue
            | _ -> raise (SemanticException {
                lnum = line_num;
                message = "Invalid arguments, toss requires either a relative direction or no arguments"
              })
          end
        | "turn" -> begin match args with
            | meta_e :: [] ->
              let instr = Bytecode.TURN ((relative_dir_of_expr meta_e), pane_num, line_num) in
              Queue.add instr code_queue
            | _ -> raise (SemanticException {
                lnum = line_num;
                message = "Invalid arguments, turn requires one relative direction argument"
              })
          end
        | "hasFlower" -> begin match args with
            | [] ->
              let instr = Bytecode.HASFLWR (pane_num, line_num) in
              Queue.add instr code_queue
            | _ -> raise (SemanticException {
                lnum = line_num;
                message = "Invalid arguments, hasFlower requires no arguments"
              })
          end
        | "isJeroo" -> begin match args with
            | meta_e :: [] ->
              let instr = Bytecode.ISJEROO ((relative_dir_of_expr meta_e), pane_num, line_num) in
              Queue.add instr code_queue
            | _ -> raise (SemanticException {
                lnum = line_num;
                message = "Invalid arguments, isJeroo requires a relative direction"
              })
          end
        | "isFacing" -> begin match args with
            | meta_e :: [] ->
              let instr = Bytecode.FACING ((compass_dir_of_expr meta_e), pane_num, line_num) in
              Queue.add instr code_queue
            | _ -> raise (SemanticException {
                lnum = line_num;
                message = "Invalid arguments, isFacing requires a compass direction"
              })
          end
        | "isFlower" -> begin match args with
            | meta_e :: [] ->
              let instr = Bytecode.ISFLWR ((relative_dir_of_expr meta_e), pane_num, line_num) in
              Queue.add instr code_queue
            | _ -> raise (SemanticException {
                lnum = line_num;
                message = "Invalid arguments, isFlower requires a relative direction"
              })
          end
        | "isNet" -> begin match args with
            | meta_e :: [] ->
              let instr = Bytecode.ISNET ((relative_dir_of_expr meta_e), pane_num, line_num) in
              Queue.add instr code_queue
            | _ -> raise (SemanticException {
                lnum = line_num;
                message = "Invalid arguments, isNet requires a relative direction"
              })
          end
        | "isWater" -> begin match args with
            | meta_e :: [] ->
              let instr = Bytecode.ISWATER ((relative_dir_of_expr meta_e), pane_num, line_num) in
              Queue.add instr code_queue
            | _ -> raise (SemanticException {
                lnum = line_num;
                message = "Invalid arguments, isWater requires a relative direction"
              })
          end
        | _ ->
          (* calling a user-defined function *)
          if Hashtbl.mem fxn_tbl id then
            (* function found in table, call the function *)
            let loc = Hashtbl.find fxn_tbl id in
            Queue.add (Bytecode.CALLBK (pane_num, line_num)) code_queue;
            Queue.add (Bytecode.JUMP_LBL (loc, pane_num, line_num)) code_queue
          else
            (* function not found *)
            raise (SemanticException {
                lnum = line_num;
                message = ("Unknown function: " ^ id)
              })
      end
    | _ ->
      raise (SemanticException {
          lnum = line_num;
          message = "Unknown expression"
        })
  in

  let gen_code_decl id args line_num =
    let id_loc = Hashtbl.find jeroo_tbl id in
    match args with
    | [] ->
      Bytecode.NEW (id_loc, 0, 0, 0, Bytecode.North, line_num)
    | { a = AST.IntExpr(x); _ } :: { a = AST.IntExpr(y); _ } :: [] ->
      Bytecode.NEW (id_loc, x, y, 0, Bytecode.North, line_num)
    | { a = AST.IntExpr(x); _ } :: { a = AST.IntExpr(y); _ } :: { a = AST.IntExpr(num_flowers); _ } :: [] ->
      Bytecode.NEW (id_loc, x, y, num_flowers, Bytecode.North, line_num)
    | { a = AST.IntExpr(x); _ } :: { a = AST.IntExpr(y); _ } :: { a = AST.IntExpr(num_flowers); _ } :: direction :: [] ->
      Bytecode.NEW (id_loc, x, y, num_flowers, (compass_dir_of_expr direction), line_num)
    | _ -> raise (SemanticException {
        lnum = line_num;
        message = "Invalid Jeroo arguments"
      })
  in

  (* generates code for a statement *)
  (* takes a statement and a pane number, returns the line number of the last instruction added *)
  let rec gen_code_stmt stmt pane_num =
    match stmt with
    | AST.BlockStmt stmts ->
      (* generate code for a block statement *)
      (* fold_left will always return the line number of the last statement executed *)
      stmts
      |> List.fold_left (fun _ stmt -> gen_code_stmt stmt pane_num) 0
    | AST.ExprStmt expr ->
      (* generate code for an expression statement *)
      gen_code_expr expr pane_num;
      expr.lnum
    | AST.DeclStmt (ty, id, meta_expr) ->
      (* generate code for a Jeroo declaration *)
      let line_num = meta_expr.lnum in
      if not (String.equal ty "Jeroo") then
        raise (SemanticException {
            lnum = line_num;
            message = "Invalid type, Jeroo is the only valid type"
          })
      else begin
        Hashtbl.add jeroo_tbl id (Hashtbl.length jeroo_tbl);
        let expr = meta_expr.a in
        begin match expr with
          | AST.UnOpExpr (AST.New, { a = AST.FxnAppExpr ({ a = AST.IdExpr(ctor); _ }, args); _ }) ->
            if not (String.equal ctor "Jeroo") then
              raise (SemanticException {
                  lnum = line_num;
                  message = ("Invalid constructor: " ^ ctor ^ ", Jeroo is the only valid constructor")
                })
            else begin
              Queue.add (gen_code_decl id args line_num) code_queue;
              line_num
            end
          | _ -> raise (SemanticException {
              lnum = line_num;
              message = "Invalid right hand side of declaration, must be a Jeroo constructor"
            })
        end
      end
    | AST.IfStmt(e, stmt, line_num) ->
      (* generate code for an if statement *)
      gen_code_expr e pane_num;
      let jmp_lbl = "if_lbl_" ^ (string_of_int (Queue.length code_queue)) in
      let jmp = (Bytecode.BZ_LBL (jmp_lbl, pane_num, line_num)) in
      Queue.add jmp code_queue;
      let end_lnum = gen_code_stmt stmt pane_num in
      Queue.add (Bytecode.LABEL (jmp_lbl, pane_num, end_lnum)) code_queue;
      end_lnum
    | AST.IfElseStmt(e, s1, s2, line_num) ->
      (* generate code for an if-else statement *)
      (* generate code for the condition *)
      gen_code_expr e pane_num;
      (* if the condition is false, jump to the else block, else execute the true block *)
      let else_lbl = "else_lbl_" ^ (string_of_int (Queue.length code_queue)) in
      let else_jmp = (Bytecode.BZ_LBL (else_lbl, pane_num, line_num)) in
      Queue.add else_jmp code_queue;
      (* generate the code for the if-block *)
      let true_end_lnum = gen_code_stmt s1 pane_num in
      (* at the end of the true block, jump to the end of the if-else block *)
      let done_lbl = "done_lbl_" ^ (string_of_int (Queue.length code_queue)) in
      let done_jmp = (Bytecode.JUMP_LBL (done_lbl, pane_num, true_end_lnum)) in
      Queue.add done_jmp code_queue;
      Queue.add (Bytecode.LABEL (else_lbl, pane_num, true_end_lnum)) code_queue;
      (* generate the code for the else-block *)
      let false_end_lnum = gen_code_stmt s2 pane_num in
      Queue.add (Bytecode.LABEL (done_lbl, pane_num, false_end_lnum)) code_queue;
      false_end_lnum
    | AST.WhileStmt(e, s, line_num) ->
      (* generate code for a while statement *)
      let loop_lbl = "loop_lbl_" ^ (string_of_int (Queue.length code_queue)) in
      Queue.add (Bytecode.LABEL (loop_lbl, pane_num, line_num)) code_queue;
      gen_code_expr e pane_num;
      let done_lbl = "done_lbl_" ^ (string_of_int (Queue.length code_queue)) in
      Queue.add (Bytecode.BZ_LBL (done_lbl, pane_num, e.lnum)) code_queue;
      let end_while_lnum = gen_code_stmt s pane_num in
      Queue.add (Bytecode.JUMP_LBL (loop_lbl, pane_num, end_while_lnum)) code_queue;
      Queue.add (Bytecode.LABEL (done_lbl, pane_num, end_while_lnum)) code_queue;
      end_while_lnum
  in

  let gen_code_fxn fxn pane_num =
    Hashtbl.add fxn_tbl fxn.id fxn.id;
    Queue.add (Bytecode.LABEL (fxn.id, pane_num, fxn.start_lnum)) code_queue;
    fxn.stmts
    |> List.iter (fun stmt -> let _ = gen_code_stmt stmt pane_num in ());
    Queue.add (Bytecode.RETR (pane_num, fxn.end_lnum)) code_queue
  in

  let gen_code_main_fxn fxn =
    if not (String.equal fxn.id "main") then
      raise (SemanticException {
          lnum = fxn.end_lnum;
          message = "main function must be called main"
        })
    else begin
      gen_code_fxn fxn 0
    end
  in

  (* at the start of execution, jump to main *)
  Queue.add (Bytecode.JUMP_LBL ("main", 0, translation_unit.main_fxn.start_lnum)) code_queue;
  (* generate the code for all of the extension methods *)
  translation_unit.extension_fxns
  |> List.iter (fun fxn -> gen_code_fxn fxn 1);
  (* generate the code for the main function *)
  gen_code_main_fxn translation_unit.main_fxn;

  let code_with_labels = Queue.to_seq code_queue in
  remove_labels code_with_labels
