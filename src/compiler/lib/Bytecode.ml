type compass_direction =
  | North
  | East
  | South
  | West

type relative_direction =
  | Left
  | Right
  | Here
  | Ahead

type bytecode =
  | CSR of int * int * int
  (* the actual Jeroo bytecode doesn't have labels, so we convert labels to memory locations in a separate step *)
  | JUMP_LBL of string * int * int
  | JUMP of int * int * int
  | BZ_LBL of string * int * int
  | BZ of int * int * int
  | LABEL of string * int * int
  | NEW of int * int * int * int * compass_direction * int
  | TURN of relative_direction * int * int
  | HOP of int * int * int
  | PICK of int * int
  | TOSS of int * int
  | PLANT of int * int
  | GIVE of relative_direction * int * int
  | TRUE of int * int
  | FALSE of int * int
  | HASFLWR of int * int
  | ISNET of relative_direction * int * int
  | ISWATER of relative_direction * int * int
  | ISJEROO of relative_direction * int * int
  | ISFLWR of relative_direction * int * int
  | FACING of compass_direction * int * int
  | NOT of int * int
  | AND of int * int
  | OR of int * int
  | RETR of int * int
  | CALLBK of int * int

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
