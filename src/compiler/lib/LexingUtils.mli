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

(** Lexing utility module for Jeroo *)

(** Get the current line number from a lexbuf *)
val get_lnum : Lexing.lexbuf -> int

val get_cnum : Lexing.lexbuf -> int

(** Advance the current line number for a lexbuf by n lines *)
val next_n_lines : int -> Lexing.lexbuf -> unit

(** Counts the number of newline characters ('\n') are in a string *)
val count_lines : string -> int
