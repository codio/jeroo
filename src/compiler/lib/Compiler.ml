exception HeaderException of string

let compile code =
  let lexbuf = Lexing.from_string code in

  (* get the first line from the code and pair the header to the correct language *)
  let ast = match (String.split_on_char '\n' code) with
    | "@Java" :: _ -> JavaParser.translation_unit JavaLexer.token lexbuf
    | "@VB" :: _ -> VBParser.translation_unit VBLexer.token lexbuf
    | _ -> raise (HeaderException "Malformed Header")
  in
  Codegen.codegen ast
