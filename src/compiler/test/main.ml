open OUnit2

let () =
  let tests = test_list [JavaTests.suite; VBTests.suite; CodegenTests.suite; IntegrationTests.suite] in
  run_test_tt_main tests
