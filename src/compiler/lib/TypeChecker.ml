(****************************************************************************)
(* Jeroo is a programming language learning tool for students and teachers. *)
(* Copyright (C) <2019>  <Benjamin Konz>                                    *)
(*                                                                          *)
(* This program is free software: you can redistribute it and/or modify     *)
(* it under the terms of the GNU Affero General Public License as           *)
(* published by the Free Software Foundation, either version 3 of the       *)
(* License, or (at your option) any later version.                          *)
(*                                                                          *)
(* This program is distributed in the hope that it will be useful,          *)
(* but WITHOUT ANY WARRANTY; without even the implied warranty of           *)
(* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            *)
(* GNU Affero General Public License for more details.                      *)
(*                                                                          *)
(* You should have received a copy of the GNU Affero General Public License *)
(* along with this program.  If not, see <http://www.gnu.org/licenses/>.    *)
(****************************************************************************)

open AST

let error = "error"

type state = {
  pane : Pane.t;
}

let rec score_args actual_args expected_args =
  match (actual_args, expected_args) with
  | ([], _) -> List.length expected_args
  | (_, []) -> List.length actual_args
  | (x :: xs, y :: ys) ->
    let cost =
      if x = y then 1 else 0
    in
    (score_args xs ys) + cost

let get_not_found_message id env =
  let ids = SymbolTable.fold env [] (fun id _ l -> id :: l) in
  let ranked_ids = ids
                   |> List.map (fun s -> (StringUtils.str_distance id s), s)
                   |> List.sort (fun a b -> compare (fst a) (fst b))
  in
  let hint =
    match ranked_ids with
    | (rank, best_match_id) :: _ when rank < 3 ->
      "\n" ^ "hint: did you mean: " ^ best_match_id ^ "?"
    | _ -> ""
  in
  id ^ " not found in this scope" ^ hint

let rank_fxns env actual_id actual_args_t =
  (SymbolTable.fold env [] (fun k v l -> (k, v) :: l))
  |> List.filter_map (fun (id, jeroo_type) -> match jeroo_type with
      | JerooType.FunT fxn when fxn.id = actual_id ->
        Some (id, jeroo_type, score_args actual_args_t fxn.args)
      | _ -> None
    )
  |> List.sort (fun (_, _, score1) (_, _, score2) -> compare score1 score2)
  |> List.map (fun (_, jeroo_type, _) -> JerooType.string_of_type jeroo_type)

let rank_ctors env actual_args_t =
  (SymbolTable.fold env [] (fun k v l -> (k, v) :: l))
  |> List.filter_map (fun (id, jeroo_type) -> match jeroo_type with
      | JerooType.CtorT ctor ->
        Some (id, jeroo_type, score_args actual_args_t ctor.args)
      | _ -> None
    )
  |> List.sort (fun (_, _, score1) (_, _, score2) -> compare score1 score2)
  |> List.map (fun (_, jeroo_type, _) -> JerooType.string_of_type jeroo_type)

let rec type_of_expr expr env state =
  match expr with
  | { a = AST.IntExpr _; _ } ->
    JerooType.NumT
  | { a = AST.TrueExpr | AST.FalseExpr; _ } ->
    JerooType.BoolT
  | { a = AST.NorthExpr | AST.SouthExpr | AST.EastExpr | AST.WestExpr; _ } ->
    JerooType.CompassDirT
  | { a = AST.AheadExpr | AST.HereExpr | AST.LeftExpr | AST.RightExpr; _ } ->
    JerooType.RelativeDirT
  | { a = AST.BinOpExpr (l, ((AST.And, op_str) | (AST.Or, op_str)), r); _ } ->
    let l_t = type_of_expr l env state in
    let r_t = type_of_expr r env state in
    begin match (l_t, r_t) with
      | JerooType.BoolT, JerooType.BoolT
        -> JerooType.BoolT
      | _ ->
        raise (Exceptions.CompileException {
            pos = l.pos;
            pane = state.pane;
            exception_type = error;
            message =
              Printf.sprintf "%s operator expected: `%s %s %s`, found: `%s %s %s`"
                op_str
                (JerooType.string_of_type JerooType.BoolT)
                op_str
                (JerooType.string_of_type JerooType.BoolT)
                (JerooType.string_of_type l_t)
                op_str
                (JerooType.string_of_type r_t)
          })
    end
  | { a = AST.UnOpExpr ((AST.Not, op_str), e); _ } ->
    begin match type_of_expr e env state with
      | JerooType.BoolT -> JerooType.BoolT
      | t -> raise (Exceptions.CompileException {
          pos = e.pos;
          pane = state.pane;
          exception_type = error;
          message =
            Printf.sprintf "%s operator expected: `%s %s`, found: `%s %s`"
              op_str
              op_str
              (JerooType.string_of_type JerooType.BoolT)
              op_str
              (JerooType.string_of_type t)
        })
    end
  | { a = AST.IdExpr id; pos } ->
    begin match (SymbolTable.find env id) with
      | Some t -> t
      | None -> raise (Exceptions.CompileException {
          pos;
          pane = Pane.Main;
          exception_type = error;
          message = get_not_found_message id env
        })
    end
  | { a = AST.UnOpExpr ((AST.New, op_str), ctor_meta); _ } ->
    begin match ctor_meta.a with
      | AST.FxnAppExpr({ a = AST.IdExpr(id); _ }, args) ->
        let args_t = args |> List.map (fun arg -> type_of_expr arg env state) in
        begin match SymbolTable.find env id with
          | Some (JerooType.ObjectT obj) ->
            let matches = SymbolTable.find_all obj.env id in
            let ctor = matches |> List.find_opt (function
                | JerooType.CtorT ctor -> ctor.args = args_t
                |  t ->
                  (* the function we are calling is not a constructor, but has the Jeroo identifier *)
                  raise (Exceptions.CompileException {
                      pos = ctor_meta.pos;
                      pane = state.pane;
                      exception_type = error;
                      message = "Expected Jeroo constructor, found " ^ (JerooType.string_of_type t)
                    })
              )
            in
            begin match ctor with
              | Some(JerooType.CtorT _) ->
                JerooType.ObjectT obj
              | _ ->
                (* construcotr has the wrong args *)
                let actual_ctor = JerooType.CtorT {
                    id;
                    args = args_t;
                  }
                in
                let message = "No match found for constructor with type: " ^
                              (JerooType.string_of_type actual_ctor) ^ "\n"
                in
                let ctors = rank_ctors obj.env args_t in
                raise (Exceptions.CompileException {
                    pos = ctor_meta.pos;
                    pane = state.pane;
                    exception_type = error;
                    message =
                      if ((List.length ctors) > 0)
                      then message ^ "Candidate constructors:\n" ^ (String.concat "\n" ctors)
                      else message
                  })
            end
          | Some(t) -> raise (Exceptions.CompileException {
              pos = ctor_meta.pos;
              pane = state.pane;
              exception_type = error;
              message =
                Printf.sprintf
                "`%s` operator must be used with an object constructor, found %s"
                op_str
                (JerooType.string_of_type t)
            })
          | None -> raise (Exceptions.CompileException {
              pos = ctor_meta.pos;
              pane = state.pane;
              exception_type = error;
              message = get_not_found_message id env
            })
        end
      | _ -> raise (Exceptions.CompileException {
          pos = ctor_meta.pos;
          pane = state.pane;
          exception_type = error;
          message =
            Printf.sprintf
            "`%s` operator requiers function application"
            op_str
        })
    end
  | { a = AST.FxnAppExpr (fxn, args); _ } -> typecheck_fxn_app fxn args env state
  | { a = AST.BinOpExpr (l, (AST.Dot, op_str), r); _ } ->
    begin match type_of_expr l env state with
      | JerooType.ObjectT obj -> type_of_expr r obj.env state
      | t -> raise (Exceptions.CompileException {
          pos = l.pos;
          pane = state.pane;
          exception_type = error;
          message =
            Printf.sprintf "%s operator must be used with a Jeroo object, found %s"
              op_str
              (JerooType.string_of_type t)
        })
    end
and typecheck_fxn_app fxn args env state = match fxn.a with
  | AST.IdExpr id ->
    let args_t = args |> List.map (fun arg -> type_of_expr arg env state) in
    let matches = SymbolTable.find_all env id in
    if (List.length matches) > 0
    then
      let fxns = matches |> List.find_opt (function
          | JerooType.FunT f -> f.args = args_t
          | t -> (* case where we found an identifier, but it wasn't a function *)
            raise (Exceptions.CompileException {
                pos = fxn.pos;
                pane = state.pane;
                exception_type = error;
                message = "call requires function, found " ^ JerooType.string_of_type t
              })
        )
      in
      match fxns with
      | Some(JerooType.FunT f) -> f.retT
      | _ -> (* case where we found an identifier that was a function, but the wrong arguments are applied *)
        let actual_fxn = JerooType.FunT {
            id;
            args = args_t;
            retT = JerooType.VoidT;
          }
        in
        let message = "No match found for function with type: " ^
                      (JerooType.string_of_type actual_fxn) ^ "\n"
        in
        let fxns = rank_fxns env id args_t in
        raise (Exceptions.CompileException {
            pos = fxn.pos;
            pane = state.pane;
            exception_type = error;
            message =
              if ((List.length fxns) > 0)
              then message ^ "Candidate functions:\n" ^ (String.concat "\n" fxns)
              else message
          })
    else
      raise (Exceptions.CompileException {
          pos = fxn.pos;
          pane = state.pane;
          exception_type = error;
          message = get_not_found_message id env;
        })
  | _ -> raise (Exceptions.CompileException {
      pos = fxn.pos;
      pane = state.pane;
      exception_type = error;
      message = "Function application must be used with an identifier"
    })

let rec typecheck_stmt stmt env state =
  match stmt with
  | AST.IfStmt { a = (e, s); pos }  ->
    begin match (type_of_expr e env state) with
      | JerooType.BoolT ->
        (typecheck_stmt s (SymbolTable.add_level env) state);
      | t -> raise (Exceptions.CompileException {
          pos;
          pane = state.pane;
          exception_type = error;
          message =
            Printf.sprintf
              "If statement expected %s, found %s"
              (JerooType.string_of_type JerooType.BoolT)
              (JerooType.string_of_type t)
        })
    end
  | AST.IfElseStmt { a = (e, s1, s2); pos } ->
    begin match (type_of_expr e env state) with
      | JerooType.BoolT ->
        (typecheck_stmt s1 (SymbolTable.add_level env) state);
        (typecheck_stmt s2 (SymbolTable.add_level env) state);
      | t -> raise (Exceptions.CompileException {
          pos;
          pane = state.pane;
          exception_type = error;
          message =
            Printf.sprintf
              "If statement expected %s, found %s"
              (JerooType.string_of_type JerooType.BoolT)
              (JerooType.string_of_type t)
        })
    end
  | AST.BlockStmt stmts ->
    stmts
    |> List.iter (fun s -> (typecheck_stmt s env state))
    ;
  | AST.WhileStmt { a = (e, s); pos } ->
    begin match (type_of_expr e env state) with
      | JerooType.BoolT ->
        (typecheck_stmt s (SymbolTable.add_level env) state);
      | t -> raise (Exceptions.CompileException {
          pos;
          pane = state.pane;
          exception_type = error;
          message =
            Printf.sprintf
              "While statement expected %s, found %s"
              (JerooType.string_of_type JerooType.BoolT)
              (JerooType.string_of_type t)
        })
    end
  | AST.ExprStmt e ->
    begin match e with
      | { a = Some e; _ } ->
        ignore (type_of_expr e env state);
      | _ -> ()
    end
  | AST.DeclStmt (ty_id, id, e) ->
    if SymbolTable.mem env id then raise (Exceptions.CompileException {
        pos = e.pos;
        pane = state.pane;
        exception_type = error;
        message = id ^ " already declared"
      });
    match type_of_expr e env state with
    | (JerooType.ObjectT obj) as t when ty_id = obj.id ->
      SymbolTable.add env id t
    | _ -> raise (Exceptions.CompileException {
        pos = e.pos;
        pane = state.pane;
        exception_type = error;
        message = "Jeroo declarations are the only valid declarations"
      })


let add_fxn_to_symbol_table id args retT env =
  let fxn = JerooType.FunT {
      id;
      args;
      retT
    }
  in
  SymbolTable.add env id fxn

let add_ctor_to_symbol_table id args env =
  let ctor = JerooType.CtorT {
      id;
      args
    }
  in
  SymbolTable.add env id ctor

let create_jeroo_env () =
  let jeroo_env = SymbolTable.create () in

  (* Action Methods *)
  add_fxn_to_symbol_table "hop" [] JerooType.VoidT jeroo_env;
  add_fxn_to_symbol_table "hop" [JerooType.NumT] JerooType.VoidT jeroo_env;
  add_fxn_to_symbol_table "pick" [] JerooType.VoidT jeroo_env;
  add_fxn_to_symbol_table "plant" [] JerooType.VoidT jeroo_env;
  add_fxn_to_symbol_table "toss" [] JerooType.VoidT jeroo_env;
  add_fxn_to_symbol_table "give" [] JerooType.VoidT jeroo_env;
  add_fxn_to_symbol_table "give" [JerooType.RelativeDirT] JerooType.VoidT jeroo_env;
  add_fxn_to_symbol_table "turn" [JerooType.RelativeDirT] JerooType.VoidT jeroo_env;

  (* Boolean Methods *)
  add_fxn_to_symbol_table "hasFlower" [] JerooType.BoolT jeroo_env;
  add_fxn_to_symbol_table "isFacing" [JerooType.CompassDirT] JerooType.BoolT jeroo_env;
  add_fxn_to_symbol_table "isFlower" [JerooType.RelativeDirT] JerooType.BoolT jeroo_env;
  add_fxn_to_symbol_table "isJeroo" [JerooType.RelativeDirT] JerooType.BoolT jeroo_env;
  add_fxn_to_symbol_table "isNet" [JerooType.RelativeDirT] JerooType.BoolT jeroo_env;
  add_fxn_to_symbol_table "isWater" [JerooType.RelativeDirT] JerooType.BoolT jeroo_env;
  add_fxn_to_symbol_table "isClear" [JerooType.RelativeDirT] JerooType.BoolT jeroo_env;

  (* Constructors *)
  let ctor_id = "Jeroo" in
  add_ctor_to_symbol_table ctor_id [] jeroo_env;
  add_ctor_to_symbol_table ctor_id [JerooType.NumT] jeroo_env;
  add_ctor_to_symbol_table ctor_id [JerooType.NumT; JerooType.NumT] jeroo_env;
  add_ctor_to_symbol_table ctor_id [JerooType.NumT; JerooType.NumT; JerooType.NumT] jeroo_env;
  add_ctor_to_symbol_table ctor_id [JerooType.NumT; JerooType.NumT; JerooType.CompassDirT] jeroo_env;
  add_ctor_to_symbol_table ctor_id [JerooType.NumT; JerooType.NumT; JerooType.CompassDirT; JerooType.NumT] jeroo_env;

  jeroo_env

let check_duplicates fxn_type id env state =
  let duplicate_found = (SymbolTable.find_all env id)
                        |> List.exists (function
                            | (JerooType.FunT _) as t -> fxn_type = t
                            | _ -> false)
  in
  if duplicate_found
  then raise (Exceptions.CompileException {
      pos = { lnum = 0; cnum = 0; };
      pane = state.pane;
      exception_type = error;
      message = (JerooType.string_of_type fxn_type) ^ " already declared"
    })

let typecheck_fxn (fxn : AST.fxn) env state =
  let new_tbl = SymbolTable.add_level env in
  fxn.stmts
  |> List.iter (fun s -> typecheck_stmt s new_tbl state)

let typecheck_extension_fxns extension_fxns env state =
  extension_fxns
  |> List.iter (fun f -> typecheck_fxn f.a env state)

let typecheck_main_fxn main_fxn env state =
  let id = "main" in
  let fxn_type = JerooType.FunT {
      id;
      args = [];
      retT = JerooType.VoidT
    }
  in
  SymbolTable.add env id fxn_type;
  let new_tbl = SymbolTable.add_level env in
  main_fxn.stmts
  |> List.iter (fun s -> typecheck_stmt s new_tbl state)

let add_extension_fxns_to_env extension_fxns env state =
  extension_fxns
  |> List.iter (fun fxn ->
      let fxn_t = JerooType.FunT {
          id = fxn.a.id;
          args = [];
          retT = JerooType.VoidT;
        }
      in
      check_duplicates fxn_t fxn.a.id env state;
      SymbolTable.add env fxn.a.id fxn_t
    )

let typecheck translation_unit =
  let main_env = SymbolTable.create () in
  let extensions_env = create_jeroo_env () in
  SymbolTable.add main_env "Jeroo" (JerooType.ObjectT {
      id = "Jeroo";
      env = extensions_env;
    });

  let extensions_state = {
    pane = Pane.Extensions;
  }
  in
  add_extension_fxns_to_env translation_unit.extension_fxns extensions_env extensions_state;
  typecheck_extension_fxns translation_unit.extension_fxns extensions_env extensions_state;
  let main_state = {
    pane = Pane.Main;
  }
  in
  typecheck_main_fxn translation_unit.main_fxn.a main_env main_state
