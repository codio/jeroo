type t = {
  mutable in_main : bool;
}

let create () = {
  in_main = false;
}
