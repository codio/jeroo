(****************************************************************************)
(* Jeroo is a programming language learning tool for students and teachers. *)
(* Copyright (C) <2019>  <Benjamin Konz>                                    *)
(*                                                                          *)
(* This program is free software: you can redistribute it and/or modify     *)
(* it under the terms of the GNU Affero General Public License as           *)
(* published by the Free Software Foundation, either version 3 of the       *)
(* License, or (at your option) any later version.                          *)
(*                                                                          *)
(* This program is distributed in the hope that it will be useful,          *)
(* but WITHOUT ANY WARRANTY; without even the implied warranty of           *)
(* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            *)
(* GNU Affero General Public License for more details.                      *)
(*                                                                          *)
(* You should have received a copy of the GNU Affero General Public License *)
(* along with this program.  If not, see <http://www.gnu.org/licenses/>.    *)
(****************************************************************************)

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
