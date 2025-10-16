type value = String of string
type store = (string, value) Hashtbl.t

type state = {
  stores : (string, store) Hashtbl.t;
  mutable selected : string option;
}

let create_state () = { stores = Hashtbl.create 10; selected = None }
let value_to_string = function String s -> s
let string_to_value s = String s

let rec eval state expr =
  match expr with
  | Parser.StringLiteral s -> String s
  | Parser.Name n -> String n
  | Parser.Create name_expr ->
      let (String name) = eval state name_expr in
      if Hashtbl.mem state.stores name then
        failwith (Printf.sprintf "Store '%s' already exists" name)
      else (
        Hashtbl.add state.stores name (Hashtbl.create 10);
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
  | Parser.Set (key_expr, value_expr) -> (
      let (String key) = eval state key_expr in
      let value = eval state value_expr in
      match state.selected with
      | None -> failwith "No store selected. Use USE first."
      | Some store_name ->
          let store = Hashtbl.find state.stores store_name in
          Hashtbl.replace store key value;
          Printf.printf "Set %s = %s in store %s\n" key (value_to_string value)
            store_name;
          value)
  | Parser.Get key_expr -> (
      let (String key) = eval state key_expr in
      match state.selected with
      | None -> failwith "No store selected. Use USE first."
      | Some store_name -> (
          let store = Hashtbl.find state.stores store_name in
          match Hashtbl.find_opt store key with
          | Some value ->
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
        if Hashtbl.length store = 0 then Printf.printf "(empty)\n"
        else
          Hashtbl.iter
            (fun key value ->
              Printf.printf "  %s = %s\n" key (value_to_string value))
            store;
        Printf.printf "=== End dump ===\n";
        String store_name

let eval_program state program = List.map (fun expr -> eval state expr) program
