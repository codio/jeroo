(** Lexing utility module for Jeroo *)

(** Get the current line number from a lexbuf *)
val get_lnum : Lexing.lexbuf -> int

val get_cnum : Lexing.lexbuf -> int

(** Advance the current line number for a lexbuf by n lines *)
val next_n_lines : int -> Lexing.lexbuf -> unit

(** Counts the number of newline characters ('\n') are in a string *)
val count_lines : string -> int
