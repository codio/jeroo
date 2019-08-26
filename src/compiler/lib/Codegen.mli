(** Module to compiler AST's to a sequence of bytecode instruction *)

(** compile a syntax tree into a sequence of bytecode instructions *)
val codegen : AST.translation_unit -> (Bytecode.bytecode list * (string, int) Hashtbl.t )
