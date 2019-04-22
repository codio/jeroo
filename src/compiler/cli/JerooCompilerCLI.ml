open Lib

let str_of_instr op arg1 arg2 arg3 arg4 arg5 arg6 =
  Printf.sprintf "%s %d %d %d %d %d %d" op arg1 arg2 arg3 arg4 arg5 arg6

(* simple utility program to compile jeroo code and print the bytecode to stdout *)
let _ =
  let args = Sys.argv in
  let args_length = args |> Array.length in
  if args_length != 2 then failwith "Must have one arg, filename";
  let filename = args.(1) in
  let code = Core.In_channel.read_all filename in
  let bytecode = fst (Compiler.compile code) in

  bytecode
  |> Seq.map (fun code -> match code with
      | Bytecode.JUMP (n, pane_num, line_num) -> str_of_instr "JUMP" n 0 0 0 pane_num line_num
      | Bytecode.JUMP_LBL (_, pane_num, line_num) -> str_of_instr "JUMP" (-1) 0 0 0 pane_num line_num
      | Bytecode.BZ (n, pane_num, line_num) -> str_of_instr "BZ" n 0 0 0 pane_num line_num
      | Bytecode.BZ_LBL (_, pane_num, line_num) -> str_of_instr "BZ" (-1) 0 0 0 pane_num line_num
      | Bytecode.LABEL (_, pane_num, line_num) -> str_of_instr "JUMP" (-1) 0 0 0 pane_num line_num
      | Bytecode.CALLBK (pane_num, line_num) -> str_of_instr "CALLBK" 0 0 0 0 pane_num line_num
      | Bytecode.RETR (pane_num, line_num) -> str_of_instr "RETR" 0 0 0 0 pane_num line_num
      | Bytecode.CSR (n, pane_num, line_num) -> str_of_instr "CSR" n 0 0 0 pane_num line_num
      | Bytecode.NEW (id, x, y, num_flowers, direction, line_num) ->
        str_of_instr "NEW" id x y num_flowers (Bytecode.int_of_compass_direction direction) line_num
      | Bytecode.TURN (direction, pane_num, line_num) ->
        str_of_instr "TURN" (Bytecode.int_of_relative_direction direction) 0 0 0 pane_num line_num
      | Bytecode.HOP (n, pane_num, line_num) -> str_of_instr "HOP" n 0 0 0 pane_num line_num
      | Bytecode.TOSS (pane_num, line_num) -> str_of_instr "TOSS" 0 0 0 0 pane_num line_num
      | Bytecode.PLANT (pane_num, line_num) -> str_of_instr "PLANT" 0 0 0 0 pane_num line_num
      | Bytecode.GIVE (direction, pane_num, line_num) ->
        str_of_instr "GIVE" (Bytecode.int_of_relative_direction direction) 0 0 0 pane_num line_num
      | Bytecode.PICK (pane_num, line_num) -> str_of_instr "PICK" 0 0 0 0 pane_num line_num
      | Bytecode.TRUE (pane_num, line_num) -> str_of_instr "TRUE" 0 0 0 0 pane_num line_num
      | Bytecode.FALSE (pane_num, line_num) -> str_of_instr "FALSE" 0 0 0 0 pane_num line_num
      | Bytecode.HASFLWR (pane_num, line_num) -> str_of_instr "HASFLWR" 0 0 0 0 pane_num line_num
      | Bytecode.ISNET (direction, pane_num, line_num) ->
        str_of_instr "ISNET" (Bytecode.int_of_relative_direction direction) 0 0 0 pane_num line_num
      | Bytecode.ISWATER (direction, pane_num, line_num) ->
        str_of_instr "ISWATER" (Bytecode.int_of_relative_direction direction) 0 0 0 pane_num line_num
      | Bytecode.ISJEROO (direction, pane_num, line_num) ->
        str_of_instr "ISJEROO" (Bytecode.int_of_relative_direction direction) 0 0 0 pane_num line_num
      | Bytecode.ISFLWR (direction, pane_num, line_num) ->
        str_of_instr "ISFLWR" (Bytecode.int_of_relative_direction direction) 0 0 0 pane_num line_num
      | Bytecode.FACING (direction, pane_num, line_num) ->
        str_of_instr "FACING" (Bytecode.int_of_compass_direction direction) 0 0 0 pane_num line_num
      | Bytecode.AND (pane_num, line_num) -> str_of_instr "AND" 0 0 0 0 pane_num line_num
      | Bytecode.OR (pane_num, line_num) -> str_of_instr "OR" 0 0 0 0 pane_num line_num
      | Bytecode.NOT (pane_num, line_num) -> str_of_instr "NOT" 0 0 0 0 pane_num line_num
    )
  |> Seq.iter (fun code_str -> print_endline code_str)
