open OUnit2
open Lib

let test_join _test_ctxt =
  assert_equal "1,2,3" (StringUtils.join_string "," ["1";"2";"3"])

let test_str_distance_not_equal _test_ctxt =
  assert_equal 1 (StringUtils.str_distance "foo" "fuo")

let test_str_distance_equal _test_ctxt =
  assert_equal 0 (StringUtils.str_distance "foo" "foo")

let suite =
  "String Utils Tests">::: [
    "test join">:: test_join;
    "test str distance not equal">::test_str_distance_not_equal;
    "test str distance equal">:: test_str_distance_equal;
  ]
