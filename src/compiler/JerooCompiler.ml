open Js_of_ocaml
open Lib

let _ =
  Js.export "JerooCompiler"
    (object%js
      method compile (code : Js.js_string Js.t) =
        try
          let (bytecode, jeroo_map) = Js.to_bytestring code
                                      |> Compiler.compile
          in
          let bytecode_json = bytecode |> JerooCompilerUtils.json_of_bytecode in
          let map = (object%js end) in
          Hashtbl.iter (fun k v -> Js.Unsafe.set map v (Js.string k)) jeroo_map;
          (object%js
            val successful = Js.bool true
            val bytecode = Js.def bytecode_json [@@jsoo.optdef]
            val jerooMap = Js.def map [@@jsoo.optdef]
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
            val jerooMap = Js.undefined [@@jsoo.optdef]
            val error = Js.def error_message [@@jsoo.optdef]
          end)
    end)
