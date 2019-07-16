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
      |> StringUtils.join_string ", "
    in
    f.id ^ "(" ^  args_str ^ ")"
  | CtorT ctor ->
    let args_str =
      ctor.args
      |> List.map string_of_type
      |> StringUtils.join_string ", "
    in
    ctor.id ^ "(" ^ args_str ^ ")"
