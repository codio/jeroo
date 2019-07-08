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
        | Exceptions.CompileException e ->
          let error_message = (Printf.sprintf "%s:Line %d:Column %d:%s:%s\n" (Pane.string_of_pane e.pane) e.pos.lnum e.pos.cnum e.exception_type e.message)
                              |> Js.string
          in
          (object%js
            val successful = Js.bool false
            val bytecode = Js.undefined [@@jsoo.optdef]
            val jerooMap = Js.undefined [@@jsoo.optdef]
            val error = Js.def error_message [@@jsoo.optdef]
          end)
        | e -> raise e
    end)
