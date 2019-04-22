open OUnit2
open Lib

let compile_java _test_ctxt =
  let code = "@Java\n\n method foo() { hop(3); }\n@@\n method main() { Jeroo j = new Jeroo(); j.foo(); }" in
  let bytecode = List.of_seq (fst (Compiler.compile code)) in
  assert_equal bytecode [
    Bytecode.JUMP (3, 0, 1);
    Bytecode.HOP (3, 1, 2);
    Bytecode.RETR (1, 2);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 1);
    Bytecode.CSR (0, 0, 1);
    Bytecode.CALLBK (0, 1);
    Bytecode.JUMP (1, 0, 1);
    Bytecode.RETR (0, 1);
  ]

let compile_VB _test_ctxt =
  let code = "@VB\n\n sub foo()\n hop(3)\n end sub\n @@\n sub main()\n dim j as Jeroo = new Jeroo()\n j.foo()\n end sub" in
  let bytecode = List.of_seq (fst (Compiler.compile code)) in
  assert_equal bytecode [
    Bytecode.JUMP (3, 0, 1);
    Bytecode.HOP (3, 1, 3);
    Bytecode.RETR (1, 4);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, 0, 3);
    Bytecode.CALLBK (0, 3);
    Bytecode.JUMP (1, 0, 3);
    Bytecode.RETR (0, 4);
  ]

let compile_Python _test_ctxt =
  let code = "@PYTHON\ndef foo(self):\n\tself.hop(3)\n@@\nj = Jeroo()\nj.foo()" in
  let bytecode = List.of_seq (fst (Compiler.compile code)) in
  assert_equal bytecode [
    Bytecode.JUMP (3, 0, 1);
    Bytecode.HOP (3, 1, 2);
    Bytecode.RETR (1, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 1);
    Bytecode.CSR (0, 0, 2);
    Bytecode.CALLBK (0, 2);
    Bytecode.JUMP (1, 0, 2);
    Bytecode.RETR (0, 3);
  ]

let suite =
  "Integration Tests">::: [
    "Compile Java">:: compile_java;
    "Compile VB">:: compile_VB;
    "Compile Python">:: compile_Python;
  ]
