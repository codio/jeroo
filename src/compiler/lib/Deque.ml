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

let create () = {
  front = Nil;
  back = Nil;
  size = 0;
}

let is_empty = function
  | { front = Nil; _ } -> true
  | _ -> false

let insert_front a t =
  t.size <- succ t.size;
  match t with
  | { front = Nil; _ } ->
    t.front <- Cons {
        next = Nil;
        prev = Nil;
        a
      };
    t.back <- t.front
  | { front = Cons front; _ } ->
    let node = Cons {
        next = t.front;
        prev = Nil;
        a
      }
    in
    front.prev <- node;
    t.front <- node

let insert_back a t =
  t.size <- succ t.size;
  match t with
  | { back = Nil; _ } ->
    t.back <- Cons {
        next = Nil;
        prev = Nil;
        a
      };
    t.front <- t.back
  | { back = Cons back; _ } ->
    let node = Cons {
        next = Nil;
        prev = t.back;
        a
      }
    in
    back.next <- node;
    t.back <- node

let delete_front t =
  match t with
  | { front = Nil; _ } -> ()
  | { front = Cons front; _ } ->
    t.size <- pred t.size;
    t.front <- front.next;

    match t.front with
    | Nil -> t.back <- Nil
    | Cons cons -> cons.prev <- Nil

let delete_back t =
  match t with
  | { back = Nil; _ } -> ()
  | { back = Cons back; _ } ->
    t.size <- pred t.size;
    t.back <- back.prev;

    match t.back with
    | Nil -> t.front <- Nil
    | Cons cons -> cons.next <- Nil

let get_front = function
  | { front = Nil; _ } -> None
  | { front = Cons cons; _ } -> Some cons.a

let get_back = function
  | { back = Nil; _ } -> None
  | { back = Cons cons; _ } -> Some cons.a

let length t = t.size

let to_list t =
  let rec f  = function
    | Nil -> []
    | Cons { next; a; _ } -> a :: (f next)
  in
  f t.front
