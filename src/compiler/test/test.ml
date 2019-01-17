open OUnit2

let test1 _test_ctxt = assert_equal "x" "x"

let suite =
  "suite">::: [
    "test1">:: test1;
  ]

let () =
  run_test_tt_main suite
