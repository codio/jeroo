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
  (* left side expression, operator, right side expression *)
  | BinOpExpr of expr meta * bin_op * expr meta
  (* operator, expression *)
  | UnOpExpr of un_op * expr meta
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
  start_lnum : int;
  end_lnum : int;
}
[@@deriving show]

type main_fxn = {
  stmts : stmt list;
  start_lnum : int;
  end_lnum : int;
}
[@@deriving show]

type language =
  | Java
  | VB
  | Python
[@@deriving show]

type translation_unit = {
  extension_fxns : fxn list;
  main_fxn : main_fxn;
  language : language
}
[@@deriving show]

let str_of_bin_op operator = function
  | Java ->
    begin match operator with
      | And -> "&&"
      | Or -> "||"
      | Dot -> "."
    end
  | VB ->
    begin match operator with
      | And -> "And"
      | Or -> "Or"
      | Dot -> "."
    end
  | Python ->
    begin match operator with
      | And -> "and"
      | Or -> "or"
      | Dot -> "."
    end

let str_of_un_op operator = function
  | Java ->
    begin match operator with
      | Not -> "!"
      | New -> "new"
    end
  | VB ->
    begin match operator with
      | Not -> "Not"
      | New -> "New"
    end
  | Python ->
    begin match operator with
      | Not -> "not"
      | New -> "="
    end
