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

type t =
  | NumT
  | BoolT
  | CompassDirT
  | RelativeDirT
  | VoidT
  | FunT of {
      id : string;
      args : t list;
      retT : t
    }
  | CtorT of {
      id : string;
      args : t list;
    }
  | ObjectT of {
      id : string;
      env : (string, t) SymbolTable.t
    }
[@@deriving show]

let rec string_of_type = function
  | NumT -> "Number"
  | BoolT -> "Boolean"
  | RelativeDirT -> "Relative Direction"
  | CompassDirT -> "Compass Direction"
  | VoidT -> "Void"
  | ObjectT { id = id; _ } -> id
  | FunT f ->
    let args_str =
      f.args
      |> List.map string_of_type
      |> String.concat ", "
    in
    f.id ^ "(" ^  args_str ^ ")"
  | CtorT ctor ->
    let args_str =
      ctor.args
      |> List.map string_of_type
      |> String.concat ", "
    in
    ctor.id ^ "(" ^ args_str ^ ")"
