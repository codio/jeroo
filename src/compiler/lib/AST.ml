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
  | SourthExpr
  | WestExpr
  | BinOpExpr of expr * string * expr
  | UnOpExpr of string * expr
  (* method, optional argument list *)
  | FxnAppExpr of string * expr list option
  (* object, method, optional arguments list *)
  | ObjFxnAppExpr of string * string * expr option list option

(* type, identifier, constructor, optional arguments list *)
type decl = string * string * string * expr list option

type stmt =
  | ExprStmt of expr
  (* condition, positive body *)
  | IfStmt of expr * decl list option * stmt list option
  (* condition, positive branch body, negative branch body *)
  | IfElseStmt of expr * (decl list option * stmt list option) * (decl list option * stmt list option)
  (* loop condition, loop body *)
  | WhileStmt of expr * decl list option * stmt list option

(* function name, function body *)
type fxn = string * decl list option * stmt list option
