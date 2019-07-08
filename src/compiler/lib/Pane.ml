type t =
  | Main
  | Extensions
[@@deriving show]

let int_of_pane = function
  | Main -> 0
  | Extensions -> 1

let string_of_pane = function
  | Main -> "Main"
  | Extensions -> "Extension Methods"
