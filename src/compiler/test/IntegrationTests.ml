open OUnit2
open Lib

let compile_java _test_ctxt =
  let code = "@Java\n\n method foo() { hop(3); }\n@@\n method main() { Jeroo j = new Jeroo(); j.foo(); }" in
  let bytecode = List.of_seq (fst (Compiler.compile code)) in
  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (3, Pane.Main, 1);
    Bytecode.HOP (3, Pane.Extensions, 2);
    Bytecode.RETR (Pane.Extensions, 2);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 1);
    Bytecode.CSR (0, Pane.Main, 1);
    Bytecode.CALLBK (Pane.Main, 1);
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.RETR (Pane.Main, 1);
  ] bytecode

let compile_VB _test_ctxt =
  let code = "@VB\n\n sub foo()\n hop(3)\n end sub\n @@\n sub main()\n dim j as Jeroo = new Jeroo()\n j.foo()\n end sub" in
  let bytecode = List.of_seq (fst (Compiler.compile code)) in
  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (3, Pane.Main, 1);
    Bytecode.HOP (3, Pane.Extensions, 3);
    Bytecode.RETR (Pane.Extensions, 4);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, Pane.Main, 3);
    Bytecode.CALLBK (Pane.Main, 3);
    Bytecode.JUMP (1, Pane.Main, 3);
    Bytecode.RETR (Pane.Main, 4);
  ] bytecode

let compile_Python _test_ctxt =
  let code = "@PYTHON\ndef foo(self):\n\tself.hop(3)\n@@\nj = Jeroo()\nj.foo()" in
  let bytecode = List.of_seq (fst (Compiler.compile code)) in
  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (3, Pane.Main, 1);
    Bytecode.HOP (3, Pane.Extensions, 2);
    Bytecode.RETR (Pane.Extensions, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 1);
    Bytecode.CSR (0, Pane.Main, 2);
    Bytecode.CALLBK (Pane.Main, 2);
    Bytecode.JUMP (1, Pane.Main, 2);
    Bytecode.RETR (Pane.Main, 3);
  ] bytecode

let suite =
  "Integration Tests">::: [
    "Compile Java">:: compile_java;
    "Compile VB">:: compile_VB;
    "Compile Python">:: compile_Python;
  ]
