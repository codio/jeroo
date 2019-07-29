type t = {
  mutable emitted_eof_nl : bool;
}

let create () =
  {
    emitted_eof_nl = false;
  }
