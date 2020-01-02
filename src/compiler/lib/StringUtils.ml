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

let str_distance s t =
  let mem = Hashtbl.create 20 in
  let rec dist i j =
    if not (Hashtbl.mem mem (i, j)) then begin
      let ans = match (i, j) with
        | (i, 0) -> i
        | (0, j) -> j
        | (i, j) ->
          if s.[i - 1] = t.[j - 1]
          then dist (i - 1) (j - 1)
          else
            let d1, d2, d3 = dist (i - 1) j, dist i (j - 1), dist (i - 1) (j - 1) in
            1 + min d1 (min d2 d3)
      in
      Hashtbl.add mem (i, j) ans
    end;
    Hashtbl.find mem (i, j)
  in
  dist (String.length s) (String.length t)
