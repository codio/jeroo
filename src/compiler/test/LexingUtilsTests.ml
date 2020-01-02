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

open OUnit2
open Lib

let get_lnum_test _test_ctxt =
  let lexbuf = Lexing.from_string "test" in
  let lnum = LexingUtils.get_lnum lexbuf in
  assert_equal lnum 1

let next_n_lines_test _test_ctxt =
  let lexbuf = Lexing.from_string "test" in
  LexingUtils.next_n_lines 4 lexbuf;
  let lnum = LexingUtils.get_lnum lexbuf in
  assert_equal lnum 5

let count_lines_test _test_ctxt =
  let s = "this\n" ^
          "is a multiline\n" ^
          "string" in
  let lines = LexingUtils.count_lines s in
  assert_equal lines 2

let suite =
  "LexiungUtils Tests">::: [
    "Get Lnum Test">:: get_lnum_test;
    "Next n Lines Test">:: next_n_lines_test;
    "Count Lines Test">:: count_lines_test;
  ]
