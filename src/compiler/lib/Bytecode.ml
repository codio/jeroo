type compass_direction =
  | North
  | East
  | South
  | West
[@@deriving show]

type relative_direction =
  | Left
  | Right
  | Here
  | Ahead
[@@deriving show]

type bytecode =
  | CSR of int * Pane.t * int
  (* the actual Jeroo bytecode doesn't have labels, so we convert labels to memory locations in a separate step *)
  | JUMP_LBL of string * Pane.t * int
  | JUMP of int * Pane.t * int
  | BZ_LBL of string * Pane.t * int
  | BZ of int * Pane.t * int
  | LABEL of string * Pane.t * int
  | NEW of int * int * int * int * compass_direction * int
  | TURN of relative_direction * Pane.t * int
  | HOP of int * Pane.t * int
  | PICK of Pane.t * int
  | TOSS of Pane.t * int
  | PLANT of Pane.t * int
  | GIVE of relative_direction * Pane.t * int
  | TRUE of Pane.t * int
  | FALSE of Pane.t * int
  | HASFLWR of Pane.t * int
  | ISNET of relative_direction * Pane.t * int
  | ISWATER of relative_direction * Pane.t * int
  | ISJEROO of relative_direction * Pane.t * int
  | ISFLWR of relative_direction * Pane.t * int
  | FACING of compass_direction * Pane.t * int
  | NOT of Pane.t * int
  | AND of Pane.t * int
  | OR of Pane.t * int
  | RETR of Pane.t * int
  | CALLBK of Pane.t * int
[@@deriving show]

let int_of_relative_direction direction = match direction with
  | Ahead -> 0
  | Here-> -1
  | Right -> 1
  | Left -> 3

let int_of_compass_direction direction = match direction with
  | North -> 0
  | East -> 1
  | South -> 2
  | West -> 3
