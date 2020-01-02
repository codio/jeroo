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

let test_add _test_ctxt =
  let table = SymbolTable.create () in
  SymbolTable.add table "foo" "bar";

  assert_equal (SymbolTable.mem table "foo") true

let test_add_level _test_ctxt =
  let root = SymbolTable.create () in
  let child1 = SymbolTable.add_level root in
  let child2 = SymbolTable.add_level root in

  SymbolTable.add child1 "foo1" "bar";
  SymbolTable.add child2 "foo2" "bar";

  assert_equal (SymbolTable.mem child1 "foo1") true;
  assert_equal (SymbolTable.mem child2 "foo2") true;
  assert_equal (SymbolTable.mem child1 "foo2") false;
  assert_equal (SymbolTable.mem child2 "foo1") false

let test_mem _test_ctxt =
  let table = SymbolTable.create () in
  SymbolTable.add table "foo" "bar";

  assert_equal (SymbolTable.mem table "foo") true;
  assert_equal (SymbolTable.mem table "bar") false

let test_find _test_ctxt =
  let table = SymbolTable.create () in
  SymbolTable.add table "foo" "bar";

  assert_equal (SymbolTable.find table "foo") (Some "bar")

let test_find_missing _test_ctxt =
  let table = SymbolTable.create () in

  assert_equal (SymbolTable.find table "foo") None

let test_multi_level_find _test_ctxt =
  let table = SymbolTable.create () in
  SymbolTable.add table "foo" "bar";
  let child = SymbolTable.add_level table in

  assert_equal (SymbolTable.find child "foo") (Some "bar")

let test_find_all _test_ctxt =
  let table = SymbolTable.create () in
  SymbolTable.add table "foo" "bar";
  let child = SymbolTable.add_level table in
  SymbolTable.add child "foo" "buzz";
  SymbolTable.add (SymbolTable.add_level table) "foo" "fizzbuzz";

  assert_equal ~printer:[%show: string list] ["buzz";"bar"] (SymbolTable.find_all child "foo")

let test_fold _test_ctxt =
  let table = SymbolTable.create () in
  SymbolTable.add table "foo" "bar";
  let child = SymbolTable.add_level table in
  SymbolTable.add child "fuu" "buzz";
  let grand_child = SymbolTable.add_level child in
  SymbolTable.add grand_child "fizzbuzz" "foo";

  assert_equal ~printer:[%show: string list] ["foo";"fuu";"fizzbuzz"] (SymbolTable.fold grand_child [] (fun k _ l -> k :: l))

let test_inverse_fold _test_ctxt =
  let table = SymbolTable.create () in
  SymbolTable.add table "foo" "bar";
  let child1 = SymbolTable.add_level table in
  SymbolTable.add child1 "foo2" "bar";
  SymbolTable.add child1 "bar2" "bar";
  let child2 = SymbolTable.add_level child1 in
  SymbolTable.add child2 "foo3" "bar";
  let child3 = SymbolTable.add_level table in
  SymbolTable.add child3 "bar3" "bar";

  assert_equal ~printer:[%show: string list] ["foo3"; "foo2"; "bar2"; "bar3"; "foo"] (SymbolTable.inverse_fold table [] (fun k _ l -> k :: l))

let suite =
  "Symbol Table Tests">::: [
    "Test add">:: test_add;
    "Test add level">:: test_add_level;
    "Test mem">:: test_mem;
    "Test find">:: test_find;
    "Test find missing">:: test_find_missing;
    "Test multi-level find">:: test_multi_level_find;
    "Test find all">:: test_find_all;
    "Test fold">:: test_fold;
    "Test inverse fold">::test_inverse_fold;
  ]
