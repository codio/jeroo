open Js_of_ocaml
open Lib

let ocaml_str_of_js_str (s : Js.js_string Js.t) =
  let length = s##.length in
  let ocaml_str = Bytes.create length in
  for i = 0 to length - 1 do
    let code = int_of_float (s##charCodeAt i) in
    let char = Char.chr code in
    Bytes.set ocaml_str i char;
  done;
  Bytes.to_string ocaml_str

let compile code =
  let code = ocaml_str_of_js_str code in
  let lexbuf = Lexing.from_string code in
  Parser.translation_unit Lexer.token lexbuf

let _ =
  Js.export "compiler"
    (object%js
      method compile (code : Js.js_string Js.t) = compile code
    end)
