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

let compile_java _test_ctxt =
  let code =
    "@Java\n" ^
    "\n" ^
    "method foo() { hop(3); }\n" ^
    "@@\n" ^
    "method main() { Jeroo j = new Jeroo(); j.foo(); }"
  in
  let bytecode = (fst (Compiler.compile code)) in
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
  let code =
    "@VB\n" ^
    "\n" ^
    "sub foo()\n" ^
    "hop(3)\n" ^
    "end sub\n" ^
    "@@\n" ^
    "sub main()\n" ^
    "dim j as Jeroo = new Jeroo()\n" ^
    "j.foo()\n" ^
    "end sub"
  in
  let bytecode = (fst (Compiler.compile code)) in
  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (3, Pane.Main, 1);
    Bytecode.HOP (3, Pane.Extensions, 3);
    Bytecode.RETR (Pane.Extensions, 3);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, Pane.Main, 3);
    Bytecode.CALLBK (Pane.Main, 3);
    Bytecode.JUMP (1, Pane.Main, 3);
    Bytecode.RETR (Pane.Main, 3);
  ] bytecode

let compile_python _test_ctxt =
  let code =
    "@PYTHON\n" ^
    "def foo(self):\n" ^
    "\tself.hop(3)\n" ^
    "@@\n" ^
    "j = Jeroo()\n" ^
    "j.foo()"
  in
  let bytecode = (fst (Compiler.compile code)) in
  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (3, Pane.Main, 1);
    Bytecode.HOP (3, Pane.Extensions, 2);
    Bytecode.RETR (Pane.Extensions, 2);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 1);
    Bytecode.CSR (0, Pane.Main, 2);
    Bytecode.CALLBK (Pane.Main, 2);
    Bytecode.JUMP (1, Pane.Main, 2);
    Bytecode.RETR (Pane.Main, 2);
  ] bytecode

let suite =
  "Integration Tests">::: [
    "Compile Java">:: compile_java;
    "Compile VB">:: compile_VB;
    "Compile Python">:: compile_python;
  ]
