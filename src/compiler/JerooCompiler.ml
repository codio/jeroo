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
          let error = (object%js
            val pane = Pane.int_of_pane e.pane
            val lnum = e.pos.lnum
            val cnum = e.pos.cnum
            val exceptionType = Js.string e.exception_type
            val message = Js.string e.message
          end)
          in
          (object%js
            val successful = Js.bool false
            val bytecode = Js.undefined [@@jsoo.optdef]
            val jerooMap = Js.undefined [@@jsoo.optdef]
            val error = Js.def error [@@jsoo.optdef]
          end)
        | e -> raise e
    end)
