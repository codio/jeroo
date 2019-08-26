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

val create : unit -> 'a t

val insert_front : 'a -> 'a t -> unit

val insert_back : 'a -> 'a t -> unit

val delete_front : 'a t -> unit

val delete_back : 'a t -> unit

val get_front : 'a t -> 'a option

val get_back : 'a t -> 'a option

val is_empty : 'a t -> bool

val length : 'a t -> int

val to_list : 'a t -> 'a list
