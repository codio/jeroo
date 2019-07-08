type t = {
  mutable in_main : bool;
  mutable emitted_eof_nl : bool;
}

let create () =
  {
    in_main = false;
    emitted_eof_nl = false;
  }
