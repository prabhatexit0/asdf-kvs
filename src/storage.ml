type data =
  | Int32 of int32
  | Int64 of int64
  | Float32 of float
  | Float64 of float
  | String of string

module type Storage = sig
  type t
  type data_type = data

  val create : unit -> t
  val set : t -> string -> data_type -> unit
  val get : t -> string -> data_type option
  val delete : t -> string -> bool
  val exists : t -> string -> bool
  val size : t -> int
  val is_empty : t -> bool
  val clear : t -> unit
  val iter : (string -> data_type -> unit) -> t -> unit
  val fold : ('a -> string -> data_type -> 'a) -> 'a -> t -> 'a
  val keys : t -> string list
  val values : t -> data_type list
  val data_to_string : data_type -> string
  val dump : t -> unit
end

module LinkedListStorage : Storage = struct
  type data_type = data
  type node = { key : string; data : data; mutable next : node option }
  type t = { mutable head : node option; mutable size : int }

  let create () = { head = None; size = 0 }
  let make_node key data next = { key; data; next }

  let set storage key data =
    let rec update_or_append current prev =
      match current with
      | None ->
          let new_node = make_node key data None in
          (match prev with
          | None -> storage.head <- Some new_node
          | Some prev_node -> prev_node.next <- Some new_node);
          storage.size <- storage.size + 1
      | Some node ->
          if node.key = key then
            let new_node = make_node key data node.next in
            match prev with
            | None -> storage.head <- Some new_node
            | Some prev_node -> prev_node.next <- Some new_node
          else update_or_append node.next (Some node)
    in
    update_or_append storage.head None

  let get storage key =
    let rec search = function
      | None -> None
      | Some node -> if node.key = key then Some node.data else search node.next
    in
    search storage.head

  let delete storage key =
    let rec remove current prev =
      match current with
      | None -> false
      | Some node ->
          if node.key = key then (
            (match prev with
            | None -> storage.head <- node.next
            | Some prev_node -> prev_node.next <- node.next);
            storage.size <- storage.size - 1;
            true)
          else remove node.next (Some node)
    in
    remove storage.head None

  let exists storage key =
    match get storage key with None -> false | Some _ -> true

  let size storage = storage.size
  let is_empty storage = storage.size = 0

  let clear storage =
    storage.head <- None;
    storage.size <- 0

  let iter f storage =
    let rec traverse = function
      | None -> ()
      | Some node ->
          f node.key node.data;
          traverse node.next
    in
    traverse storage.head

  let fold f init storage =
    let rec traverse acc = function
      | None -> acc
      | Some node ->
          let new_acc = f acc node.key node.data in
          traverse new_acc node.next
    in
    traverse init storage.head

  let keys storage = fold (fun acc key _ -> key :: acc) [] storage |> List.rev

  let values storage =
    fold (fun acc _ data -> data :: acc) [] storage |> List.rev

  let data_to_string = function
    | Int32 i -> Int32.to_string i ^ "i32"
    | Int64 i -> Int64.to_string i ^ "i64"
    | Float32 f -> string_of_float f ^ "f32"
    | Float64 f -> string_of_float f ^ "f64"
    | String s -> "\"" ^ s ^ "\""

  let dump storage =
    Printf.printf "=== Storage dump (size: %d) ===\n" storage.size;
    if is_empty storage then Printf.printf "(empty)\n"
    else
      iter
        (fun key data -> Printf.printf "  %s = %s\n" key (data_to_string data))
        storage;
    Printf.printf "=== End dump ===\n"
end

include LinkedListStorage
