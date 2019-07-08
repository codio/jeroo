let rec join_string (s : string) = function
  | x :: ((_ :: _) as xs) -> x ^ s ^ (join_string s xs)
  | x :: [] -> x
  | [] -> ""

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
