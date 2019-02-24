type bin_op =
  | And
  | Or
  | Dot
  | Eq


type un_op =
  | Not
  | New

type 'a meta = {
  a: 'a;
  lnum: int;
}

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
  (* object, method, arguments list *)
  | ObjFxnAppExpr of string * string * expr meta list


type stmt =
  | BlockStmt of stmt list
  (* condition, positive body, line num *)
  | IfStmt of expr meta * stmt * int
  (* condition, positive branch body, negative branch body, line num *)
  | IfElseStmt of expr meta * stmt * stmt * int
  (* loop condition, loop body, line num *)
  | WhileStmt of expr meta * stmt * int
  (* type, identifier, initialization expression *)
  | DeclStmt of string * string * expr meta
  | ExprStmt of expr meta


type fxn = {
  id : string;
  stmts : stmt list;
  start_lnum: int;
  end_lnum: int;
}

type translation_unit = {
  extension_fxns: fxn list;
  main_fxn: fxn;
}
