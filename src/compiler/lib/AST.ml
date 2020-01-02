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

type bin_op =
  | And
  | Or
  | Dot
[@@deriving show]

type un_op =
  | Not
  | New
[@@deriving show]

type 'a meta = {
  a : 'a;
  pos : Position.t
}
[@@deriving show]

type expr =
  | IdExpr of string
  | IntExpr of int
  | TrueExpr
  | FalseExpr
  | LeftExpr
  | RightExpr
  | AheadExpr
  | HereExpr
  | NorthExpr
  | EastExpr
  | SouthExpr
  | WestExpr
  (* left side expression, operator with associated text, right side expression *)
  | BinOpExpr of expr meta * (bin_op * string) * expr meta
  (* uniary operator with associated text, expression *)
  | UnOpExpr of (un_op * string) * expr meta
  (* expression, arguments *)
  | FxnAppExpr of expr meta * expr meta list
[@@deriving show]

type stmt =
  | BlockStmt of stmt list
  (* condition, positive body *)
  | IfStmt of (expr meta * stmt) meta
  (* condition, positive branch body, negative branch body *)
  | IfElseStmt of (expr meta * stmt * stmt) meta
  (* loop condition, loop body *)
  | WhileStmt of (expr meta * stmt) meta
  (* type, identifier, initialization expression *)
  | DeclStmt of string * string * expr meta
  | ExprStmt of expr meta option meta
[@@deriving show]

type fxn = {
  id : string;
  stmts : stmt list;
}
[@@deriving show]

type main_fxn = {
  stmts : stmt list;
}
[@@deriving show]

type translation_unit = {
  extension_fxns : fxn meta list;
  main_fxn : main_fxn meta
}
[@@deriving show]

let rec stmt_pos = function
  | BlockStmt stmts ->
    (* get the position of the first statement, if it exists *)
    let stmt_opt = (List.nth_opt stmts 0) in
    Option.bind stmt_opt stmt_pos
  | IfStmt { pos; _ }
  | IfElseStmt { pos; _ }
  | WhileStmt { pos; _ }
  | ExprStmt { pos; _ }
  | DeclStmt (_, _, { pos; _ }) -> Some pos
