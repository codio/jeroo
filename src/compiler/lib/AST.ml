type bin_op = [
  | `And
  | `Or
  | `Dot
  | `Eq
]

type un_op = [
  | `Not
  | `New
]

type expr = [
  | `IdExpr of string
  | `IntExpr of int
  | `TrueExpr
  | `FalseExpr
  | `LeftExpr
  | `RightExpr
  | `AheadExpr
  | `HereExpr
  | `NorthExpr
  | `EastExpr
  | `SouthExpr
  | `WestExpr
  | `BinOpExpr of expr * bin_op * expr
  | `UnOpExpr of un_op * expr
  | `FxnAppExpr of expr * expr list
  (* object, method, arguments list *)
  | `ObjFxnAppExpr of string * string * expr list
]

type stmt = [
  | `BlockStmt of stmt list
  (* condition, positive body *)
  | `IfStmt of expr * stmt
  (* condition, positive branch body, negative branch body *)
  | `IfElseStmt of expr * stmt * stmt
  (* loop condition, loop body *)
  | `WhileStmt of expr * stmt
  (* type, identifier, initialization expression *)
  | `DeclStmt of string * string * expr
  | `ExprStmt of expr
]

(* function name, function body *)
type fxn = string * stmt list
