type t = {
  mutable curr_offset : int;
  offset_stack : int Stack.t;
  mutable nl_ignore : int;
  mutable emitted_eof_nl : bool;
}

let create () =
  let stack = Stack.create() in
  stack |> Stack.push 0;
  {
    curr_offset = 0;
    offset_stack = stack;
    nl_ignore = 0;
    emitted_eof_nl = false;
  }
