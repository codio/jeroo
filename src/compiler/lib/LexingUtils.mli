(** Lexing utility module for Jeroo *)

(** Get the current line number from a lexbuf *)
val get_lnum : Lexing.lexbuf -> int

(** Advance the current line number for a lexbuf by n lines *)
val next_n_lines : int -> Lexing.lexbuf -> unit

(** Set the current line number for a lexbuf to 1 *)
val reset_lnum : Lexing.lexbuf -> unit
