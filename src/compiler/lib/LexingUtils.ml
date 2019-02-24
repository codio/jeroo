open Lexing

let get_lnum lexbuf =
  let pos = lexbuf.lex_curr_p in
  pos.pos_lnum

let next_n_lines n lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = pos.pos_lnum + n
    }

let reset_lnum lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = 1
    }
