open Lexing

let get_lnum lexbuf =
  let pos = lexbuf.lex_curr_p in
  pos.pos_lnum

let get_cnum lexbuf =
  let pos = lexbuf.lex_curr_p in
  pos.pos_cnum - pos.pos_bol

let next_n_lines n lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with
      pos_bol = pos.pos_cnum;
               pos_lnum = pos.pos_lnum + n
    }

let count_lines s =
  s
  |> String.to_seq
  |> Seq.fold_left (fun acc c -> if c = '\n' then succ acc else acc) 0
