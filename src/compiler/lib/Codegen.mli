(** Module to compiler AST's to a sequence of bytecode instruction *)

(** compile a syntax tree into a sequence of bytecode instructions *)
val codegen : AST.translation_unit -> (Bytecode.bytecode Seq.t * (string, int) Hashtbl.t )
