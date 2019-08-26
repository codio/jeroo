open OUnit2
open Lib

let test_insert_front _test_ctxt =
  let deque = Deque.create () in
  Deque.insert_front 1 deque;
  Deque.insert_front 2 deque;

  let front = Deque.get_front deque in
  let back = Deque.get_back deque in
  assert_equal ~printer:[%derive.show: int option] front (Some 2);
  assert_equal ~printer:[%derive.show: int option] back (Some 1)

let test_insert_back _test_ctxt =
  let deque = Deque.create () in
  Deque.insert_back 1 deque;
  Deque.insert_back 2 deque;

  let front = Deque.get_front deque in
  let back = Deque.get_back deque in
  assert_equal ~printer:[%derive.show: int option] front (Some 1);
  assert_equal ~printer:[%derive.show: int option] back (Some 2)

let test_delete_front _test_ctxt =
  let deque = Deque.create () in
  Deque.insert_front 1 deque;
  Deque.insert_front 2 deque;

  Deque.delete_front deque;

  let front = Deque.get_front deque in
  let back = Deque.get_back deque in
  assert_equal ~printer:[%derive.show: int option] front (Some 1);
  assert_equal ~printer:[%derive.show: int option] back (Some 1)

let test_delete_back _test_ctxt =
  let deque = Deque.create () in
  Deque.insert_front 1 deque;
  Deque.insert_front 2 deque;

  Deque.delete_back deque;

  let front = Deque.get_front deque in
  let back = Deque.get_back deque in
  assert_equal ~printer:[%derive.show: int option] front (Some 2);
  assert_equal ~printer:[%derive.show: int option] back (Some 2)

let test_delete_front_one_element _test_ctxt =
  let deque = Deque.create () in
  Deque.insert_front 1 deque;

  Deque.delete_front deque;

  let front = Deque.get_front deque in
  let back = Deque.get_back deque in
  assert_equal  ~printer:[%derive.show: int option] front None;
  assert_equal  ~printer:[%derive.show: int option] back None

let test_delete_back_one_element _test_ctxt =
  let deque = Deque.create () in
  Deque.insert_front 1 deque;

  Deque.delete_back deque;

  let front = Deque.get_front deque in
  let back = Deque.get_back deque in
  assert_equal ~printer:[%derive.show: int option] front None;
  assert_equal ~printer:[%derive.show: int option] back None

let test_delete_front_underflow _test_ctxt =
  let deque = Deque.create () in
  Deque.delete_front deque;

  let length = Deque.length deque in
  assert_equal ~printer:string_of_int length 0

let test_delete_back_underflow _test_ctxt =
  let deque = Deque.create () in
  Deque.delete_back deque;

  let length = Deque.length deque in
  assert_equal ~printer:string_of_int length 0

let test_to_list _test_ctxt =
  let deque = Deque.create () in
  Deque.insert_back 1 deque;
  Deque.insert_back 2 deque;
  Deque.insert_back 3 deque;
  Deque.insert_front 4 deque;
  Deque.insert_front 5 deque;

  let l = Deque.to_list deque in
  assert_equal ~printer:[%derive.show: int list] l [5; 4; 1; 2; 3]

let test_length _test_ctxt =
  let deque = Deque.create () in
  Deque.insert_back 1 deque;
  Deque.insert_back 2 deque;
  Deque.insert_front 5 deque;
  Deque.delete_back deque;
  Deque.delete_front deque;

  let length = Deque.length deque in
  assert_equal ~printer:string_of_int length 1

let test_is_empty_true _test_ctxt =
  let deque = Deque.create () in
  Deque.insert_back 1 deque;
  Deque.delete_back deque;

  let is_empty = Deque.is_empty deque in
  assert_equal ~printer:string_of_bool is_empty true

let test_is_empty_false _test_ctxt =
  let deque = Deque.create () in
  Deque.insert_back 1 deque;

  let is_empty = Deque.is_empty deque in
  assert_equal ~printer:string_of_bool is_empty false

let suite =
  "Deque Tests">::: [
    "Test insert front" >:: test_insert_front;
    "Test insert back" >:: test_insert_back;
    "Test delete front">:: test_delete_front;
    "Test delete back">:: test_delete_back;
    "Test delete front with one element">:: test_delete_front_one_element;
    "Test delete back with one element">:: test_delete_back_one_element;
    "Test delete front underflow">:: test_delete_front_underflow;
    "Test delete back underflow">:: test_delete_back_underflow;
    "Test to list">:: test_to_list;
    "Test length">:: test_length;
    "Test is empty true">:: test_is_empty_true;
    "Test is empty false">:: test_is_empty_false;
  ]
