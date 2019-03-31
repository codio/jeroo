open Js_of_ocaml
open Lib

let _ =
  Js.export "JerooCompiler"
    (object%js
      method compile (code : Js.js_string Js.t) =
        try
          let bytecode = Js.to_bytestring code
                         |> Compiler.compile
                         |> JerooCompilerUtils.json_of_bytecode
          in
          (object%js
            val successful = Js.bool true
            val bytecode = Js.def bytecode [@@jsoo.optdef]
            val error = Js.undefined [@@jsoo.optdef]
          end)
        with
        | e ->
          let error_message = match e with
            | Codegen.SemanticException e ->
              (Printf.sprintf "Semantic error on line %d: %s\n" e.lnum e.message)
              |> Js.string
            | Compiler.ParserException e ->
              (Printf.sprintf "Syntax error on line %d: %s\n" e.lnum e.message)
              |> Js.string
            | Compiler.HeaderException e ->
              (Printf.sprintf "File header error: %s\n" e)
              |> Js.string
            | e -> raise e
          in
          (object%js
            val successful = Js.bool false
            val bytecode = Js.undefined [@@jsoo.optdef]
            val error = Js.def error_message [@@jsoo.optdef]
          end)
    end)
