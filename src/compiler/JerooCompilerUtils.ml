open Js_of_ocaml
open Lib

let new_instruction op_init arg1 arg2 arg3 arg4 arg5 arg6 =
  (object%js
    val op = Js.string op_init
    val a = arg1
    val b = arg2
    val c = arg3
    val d = arg4
    val e = arg5
    val f = arg6
  end)

let json_of_bytecode bytecode =
  bytecode
  |> Seq.map (fun code -> match code with
      | Bytecode.JUMP (n, pane_num, line_num) -> new_instruction "JUMP" n 0 0 0 pane_num line_num
      | Bytecode.JUMP_LBL (_, pane_num, line_num) -> new_instruction "JUMP" (-1) 0 0 0 pane_num line_num
      | Bytecode.BZ (n, pane_num, line_num) -> new_instruction "BZ" n 0 0 0 pane_num line_num
      | Bytecode.BZ_LBL (_, pane_num, line_num) -> new_instruction "BZ" (-1) 0 0 0 pane_num line_num
      | Bytecode.LABEL (_, pane_num, line_num) -> new_instruction "JUMP" (-1) 0 0 0 pane_num line_num
      | Bytecode.CALLBK (pane_num, line_num) -> new_instruction "CALLBK" 0 0 0 0 pane_num line_num
      | Bytecode.RETR (pane_num, line_num) -> new_instruction "RETR" 0 0 0 0 pane_num line_num
      | Bytecode.CSR (n, pane_num, line_num) -> new_instruction "CSR" n 0 0 0 pane_num line_num
      | Bytecode.NEW (id, x, y, num_flowers, direction, line_num) ->
        new_instruction "NEW" id x y num_flowers (Bytecode.int_of_compass_direction direction) line_num
      | Bytecode.TURN (direction, pane_num, line_num) ->
        new_instruction "TURN" (Bytecode.int_of_relative_direction direction) 0 0 0 pane_num line_num
      | Bytecode.HOP (n, pane_num, line_num) -> new_instruction "HOP" n 0 0 0 pane_num line_num
      | Bytecode.TOSS (pane_num, line_num) -> new_instruction "TOSS" 0 0 0 0 pane_num line_num
      | Bytecode.PLANT (pane_num, line_num) -> new_instruction "PLANT" 0 0 0 0 pane_num line_num
      | Bytecode.GIVE (direction, pane_num, line_num) ->
        new_instruction "GIVE" (Bytecode.int_of_relative_direction direction) 0 0 0 pane_num line_num
      | Bytecode.PICK (pane_num, line_num) -> new_instruction "PICK" 0 0 0 0 pane_num line_num
      | Bytecode.TRUE (pane_num, line_num) -> new_instruction "TRUE" 0 0 0 0 pane_num line_num
      | Bytecode.FALSE (pane_num, line_num) -> new_instruction "FALSE" 0 0 0 0 pane_num line_num
      | Bytecode.HASFLWR (pane_num, line_num) -> new_instruction "HASFLWR" 0 0 0 0 pane_num line_num
      | Bytecode.ISNET (direction, pane_num, line_num) ->
        new_instruction "ISNET" (Bytecode.int_of_relative_direction direction) 0 0 0 pane_num line_num
      | Bytecode.ISWATER (direction, pane_num, line_num) ->
        new_instruction "ISWATER" (Bytecode.int_of_relative_direction direction) 0 0 0 pane_num line_num
      | Bytecode.ISJEROO (direction, pane_num, line_num) ->
        new_instruction "ISJEROO" (Bytecode.int_of_relative_direction direction) 0 0 0 pane_num line_num
      | Bytecode.ISFLWR (direction, pane_num, line_num) ->
        new_instruction "ISFLWR" (Bytecode.int_of_relative_direction direction) 0 0 0 pane_num line_num
      | Bytecode.FACING (direction, pane_num, line_num) ->
        new_instruction "FACING" (Bytecode.int_of_compass_direction direction) 0 0 0 pane_num line_num
      | Bytecode.AND (pane_num, line_num) -> new_instruction "AND" 0 0 0 0 pane_num line_num
      | Bytecode.OR (pane_num, line_num) -> new_instruction "OR" 0 0 0 0 pane_num line_num
      | Bytecode.NOT (pane_num, line_num) -> new_instruction "NOT" 0 0 0 0 pane_num line_num
    )
  |> Array.of_seq
  |> Js.array
