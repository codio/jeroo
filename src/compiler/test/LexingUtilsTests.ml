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
