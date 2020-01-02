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
  |> List.map (fun code -> match code with
      | Bytecode.JUMP (n, pane, line_num) -> new_instruction "JUMP" n 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.JUMP_LBL (_, pane, line_num) -> new_instruction "JUMP" (-1) 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.BZ (n, pane, line_num) -> new_instruction "BZ" n 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.BZ_LBL (_, pane, line_num) -> new_instruction "BZ" (-1) 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.LABEL (_, pane, line_num) -> new_instruction "JUMP" (-1) 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.CALLBK (pane, line_num) -> new_instruction "CALLBK" 0 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.RETR (pane, line_num) -> new_instruction "RETR" 0 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.CSR (n, pane, line_num) -> new_instruction "CSR" n 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.NEW (id, x, y, num_flowers, direction, line_num) ->
        new_instruction "NEW" id x y num_flowers (Bytecode.int_of_compass_direction direction) line_num
      | Bytecode.TURN (direction, pane, line_num) ->
        new_instruction "TURN" (Bytecode.int_of_relative_direction direction) 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.HOP (n, pane, line_num) -> new_instruction "HOP" n 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.TOSS (pane, line_num) -> new_instruction "TOSS" 0 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.PLANT (pane, line_num) -> new_instruction "PLANT" 0 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.GIVE (direction, pane, line_num) ->
        new_instruction "GIVE" (Bytecode.int_of_relative_direction direction) 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.PICK (pane, line_num) -> new_instruction "PICK" 0 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.TRUE (pane, line_num) -> new_instruction "TRUE" 0 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.FALSE (pane, line_num) -> new_instruction "FALSE" 0 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.HASFLWR (pane, line_num) -> new_instruction "HASFLWR" 0 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.ISNET (direction, pane, line_num) ->
        new_instruction "ISNET" (Bytecode.int_of_relative_direction direction) 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.ISWATER (direction, pane, line_num) ->
        new_instruction "ISWATER" (Bytecode.int_of_relative_direction direction) 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.ISJEROO (direction, pane, line_num) ->
        new_instruction "ISJEROO" (Bytecode.int_of_relative_direction direction) 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.ISFLWR (direction, pane, line_num) ->
        new_instruction "ISFLWR" (Bytecode.int_of_relative_direction direction) 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.FACING (direction, pane, line_num) ->
        new_instruction "FACING" (Bytecode.int_of_compass_direction direction) 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.AND (pane, line_num) -> new_instruction "AND" 0 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.OR (pane, line_num) -> new_instruction "OR" 0 0 0 0 (Pane.int_of_pane pane) line_num
      | Bytecode.NOT (pane, line_num) -> new_instruction "NOT" 0 0 0 0 (Pane.int_of_pane pane) line_num
    )
  |> Array.of_list
  |> Js.array
