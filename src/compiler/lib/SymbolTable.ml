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

let add t k v =
  match t with
  | Root { table; _ } -> Hashtbl.add table k v
  | Node { table; _ } -> Hashtbl.add table k v

let add_level t =
  let new_level = Node {
      parent = t;
      children = [];
      table = Hashtbl.create 10
    }
  in
  begin match t with
    | Root root -> root.children <- new_level :: root.children
    | Node node -> node.children <- new_level :: node.children
  end;
  new_level

let rec mem t k =
  match t with
  | Root root -> Hashtbl.mem root.table k
  | Node node ->
    if (Hashtbl.mem node.table k)
    then true
    else mem node.parent k

let rec find t k =
  match t with
  | Root root -> Hashtbl.find_opt root.table k
  | Node node ->
    if (Hashtbl.mem node.table k)
    then Some (Hashtbl.find node.table k)
    else find node.parent k

let rec find_all t k =
  match t with
  | Root root -> Hashtbl.find_all root.table k
  | Node node -> (Hashtbl.find_all node.table k) @ (find_all node.parent k)

let rec iter t f =
  match t with
  | Root { table; _} ->
    Hashtbl.iter f table;
  | Node { table; parent; _ } ->
    Hashtbl.iter f table;
    iter parent f

let rec fold t c f  =
  match t with
  | Root { table; _ } -> Hashtbl.fold f table c
  | Node { table; parent; _ } -> fold parent (Hashtbl.fold f table c) f

let rec inverse_fold t c f =
  match t with
  | Root { table; children } -> List.fold_left (fun c child -> inverse_fold child c f) (Hashtbl.fold f table c) children
  | Node { table; children; _ } -> List.fold_left (fun c child -> inverse_fold child c f) (Hashtbl.fold f table c) children

let create () = Root {
    children = [];
    table = Hashtbl.create 10
  }
