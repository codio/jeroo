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

let rec show = function
  | NumT -> "NumT\n"
  | BoolT -> "BoolT\n"
  | CompassDirT -> "CompassDirT\n"
  | RelativeDirT -> "RelativeDirT\n"
  | VoidT -> "VoidT\n"
  | FunT f -> Printf.sprintf "FunT { id = %s; args = %s; retT = %s }\n" f.id (f.args |> List.fold_left (fun s t -> s ^ (show t) ^ "; ") "") (show f.retT)
  | CtorT ctor -> Printf.sprintf "CtorT { id = %s; args = %s }\n" ctor.id (ctor.args |> List.fold_left (fun s t -> s ^ (show t) ^ "; ") "")
  | ObjectT obj -> Printf.sprintf "ObjectT { id = %s; env = { %s } }\n" obj.id (SymbolTable.fold obj.env "" (fun k v s -> s ^ k ^ " = " ^ (show v)))

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
