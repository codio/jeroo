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
            val error_message = Js.undefined [@@jsoo.optdef]
          end)
        with Codegen.SemanticException e ->
          let error_message = (Printf.sprintf "Semantic exception on line %d: %s\n" e.lnum e.message)
                              |> Js.string
          in
          (object%js
            val successful = Js.bool false
            val bytecode = Js.undefined [@@jsoo.optdef]
            val error_message = Js.def error_message [@@jsoo.optdef]
          end)
    end)
