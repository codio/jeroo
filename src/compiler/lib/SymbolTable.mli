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

type ('a, 'b) t =
  | Root of {
      mutable children : ('a, 'b) t list;
      table : ('a, 'b) Hashtbl.t [@opaque];
    }
  | Node of {
      parent : ('a, 'b) t;
      mutable children : ('a, 'b) t list;
      table : ('a, 'b) Hashtbl.t [@opaque];
    }
[@@deriving show]

(** add element to the current level of the symbol table *)
val add :  ('a, 'b) t -> 'a -> 'b -> unit

(** create a new level with it's parent as the passed in table *)
val add_level : ('a, 'b) t -> ('a, 'b) t

(** search for the first instance of a key looking bottom first up to the root *)
val mem : ('a, 'b) t -> 'a -> bool

(** find the first instance of a key in the symbol table looking bottom first and return the value *)
val find : ('a, 'b) t -> 'a -> 'b option

val find_all : ('a, 'b) t -> 'a -> 'b list

(** create an empty symbol table *)
val create : unit -> ('a, 'b) t

val iter : ('a, 'b) t -> ('a -> 'b -> unit) -> unit

(** fold from bottom to the top *)
val fold : ('a, 'b) t -> 'c -> ('a -> 'b -> 'c -> 'c) -> 'c

(** fold from top to bottom, visiting all children *)
val inverse_fold : ('a, 'b) t -> 'c -> ('a -> 'b -> 'c -> 'c) -> 'c
