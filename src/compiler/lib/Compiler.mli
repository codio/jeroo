exception HeaderException of string

exception ParserException of {
    message: string;
    lnum: int;
  }

val compile : string -> (Bytecode.bytecode Seq.t * (string, int) Hashtbl.t)
