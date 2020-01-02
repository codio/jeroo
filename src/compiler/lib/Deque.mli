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

type 'a node =
  | Nil
  | Cons of {
      mutable next : 'a node;
      mutable prev : 'a node;
      a : 'a;
    }

type 'a t = {
  mutable front : 'a node;
  mutable back : 'a node;
  mutable size : int
}

val create : unit -> 'a t

val insert_front : 'a -> 'a t -> unit

val insert_back : 'a -> 'a t -> unit

val delete_front : 'a t -> unit

val delete_back : 'a t -> unit

val get_front : 'a t -> 'a option

val get_back : 'a t -> 'a option

val is_empty : 'a t -> bool

val length : 'a t -> int

val to_list : 'a t -> 'a list
