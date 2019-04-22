(** Module to compiler AST's to a sequence of bytecode instruction *)

exception SemanticException of {
    lnum : int;
    message : string;
  }

(** compile a syntax tree into a sequence of bytecode instructions *)
val codegen : AST.translation_unit -> (Bytecode.bytecode Seq.t * (string, int) Hashtbl.t )
