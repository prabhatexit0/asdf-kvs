type value = String of string
type store = Storage.t

type state = {
  stores : (string, store) Hashtbl.t;
  mutable selected : string option;
}

let create_state () = { stores = Hashtbl.create 10; selected = None }
let value_to_string = function String s -> s
let string_to_value s = String s
let value_to_storage_data = function String s -> Storage.String s

let storage_data_to_value = function
  | Storage.String s -> String s
  | Storage.Int32 i -> String (Int32.to_string i)
  | Storage.Int64 i -> String (Int64.to_string i)
  | Storage.Float32 f -> String (string_of_float f)
  | Storage.Float64 f -> String (string_of_float f)

let rec eval state = function
  | Parser.StringLiteral s -> String s
  | Parser.Name n -> String n
  | Parser.Create name_expr ->
      let (String name) = eval state name_expr in
      if Hashtbl.mem state.stores name then
        failwith (Printf.sprintf "Store '%s' already exists" name)
      else (
        Hashtbl.add state.stores name (Storage.create ());
        Printf.printf "Created store: %s\n" name;
        String name)
  | Parser.Select name_expr ->
      let (String name) = eval state name_expr in
      if not (Hashtbl.mem state.stores name) then
        failwith (Printf.sprintf "Store '%s' does not exist" name)
      else (
        state.selected <- Some name;
        Printf.printf "Selected store: %s\n" name;
        String name)
  | Parser.Unselect name_expr -> (
      let (String name) = eval state name_expr in
      match state.selected with
      | Some current when current = name ->
          state.selected <- None;
          Printf.printf "Unselected store: %s\n" name;
          String name
      | Some current ->
          failwith
            (Printf.sprintf "Cannot unselect '%s': currently selected is '%s'"
               name current)
      | None -> failwith "No store is currently selected")
  | Parser.Drop name_expr ->
      let (String name) = eval state name_expr in
      if not (Hashtbl.mem state.stores name) then
        failwith (Printf.sprintf "Store '%s' does not exist" name)
      else (
        (match state.selected with
        | Some current when current = name -> state.selected <- None
        | _ -> ());
        Hashtbl.remove state.stores name;
        Printf.printf "Dropped store: %s\n" name;
        String name)
  | Parser.Set (key_expr, dtype, value_expr) -> (
      let (String key) = eval state key_expr in
      let (String value_str) = eval state value_expr in
      match state.selected with
      | None -> failwith "No store selected. Use USE first."
      | Some store_name ->
          let store = Hashtbl.find state.stores store_name in
          let storage_data =
            match dtype with
            | Parser.I32 -> Storage.Int32 (Int32.of_string value_str)
            | Parser.I64 -> Storage.Int64 (Int64.of_string value_str)
            | Parser.F32 -> Storage.Float32 (float_of_string value_str)
            | Parser.F64 -> Storage.Float64 (float_of_string value_str)
            | Parser.String -> Storage.String value_str
          in
          Storage.set store key storage_data;
          Printf.printf "Set %s = %s in store %s\n" key
            (Storage.data_to_string storage_data)
            store_name;
          String value_str)
  | Parser.Get key_expr -> (
      let (String key) = eval state key_expr in
      match state.selected with
      | None -> failwith "No store selected. Use USE first."
      | Some store_name -> (
          let store = Hashtbl.find state.stores store_name in
          match Storage.get store key with
          | Some data ->
              let value = storage_data_to_value data in
              Printf.printf "Got %s = %s from store %s\n" key
                (value_to_string value) store_name;
              value
          | None ->
              failwith
                (Printf.sprintf "Key '%s' not found in store '%s'" key
                   store_name)))
  | Parser.Save filename_expr ->
      let (String filename) = eval state filename_expr in
      Printf.printf "TODO: Save to file %s (storage implementation pending)\n"
        filename;
      String filename
  | Parser.Load filename_expr ->
      let (String filename) = eval state filename_expr in
      Printf.printf "TODO: Load from file %s (storage implementation pending)\n"
        filename;
      String filename
  | Parser.Dump store_expr ->
      let (String store_name) = eval state store_expr in
      if not (Hashtbl.mem state.stores store_name) then
        failwith (Printf.sprintf "Store '%s' does not exist" store_name)
      else
        let store = Hashtbl.find state.stores store_name in
        Printf.printf "=== Dump of store '%s' ===\n" store_name;
        if Storage.size store = 0 then Printf.printf "(empty)\n"
        else
          Storage.iter
            (fun key data ->
              let value = storage_data_to_value data in
              Printf.printf "  %s = %s\n" key (value_to_string value))
            store;
        Printf.printf "=== End dump ===\n";
        String store_name

let eval_program state program = List.map (fun expr -> eval state expr) program
