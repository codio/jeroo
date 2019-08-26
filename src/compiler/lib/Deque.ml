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
