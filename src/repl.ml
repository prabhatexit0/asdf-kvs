let print_welcome () =
  print_endline "=== asdf-kvs REPL ===";
  print_endline "Interactive Key-Value Store";
  print_endline "";
  print_endline "Commands:";
  print_endline "  create <name>       - Create a new store";
  print_endline "  select <name>       - Select a store";
  print_endline "  unselect <name>     - Unselect a store";
  print_endline "  drop <name>         - Delete a store";
  print_endline "  set <key> <value>   - Set a key-value pair";
  print_endline "  get <key>           - Get a value";
  print_endline "  dump <store>        - Show all keys in store";
  print_endline "  save <file>         - Save store to file (stub)";
  print_endline "  load <file>         - Load store from file (stub)";
  print_endline "  exit                - Exit REPL";
  print_endline "";
  print_endline "Expressions can be nested: set get \"x\" \"y\"";
  print_endline "Multiple commands: create \"s\"; select \"s\"";
  print_endline ""

let repl () =
  print_welcome ();
  let state = Interpreter.create_state () in

  let rec loop () =
    try
      print_string "> ";
      flush stdout;
      let line = read_line () in
      let trimmed = String.trim line in

      if trimmed = "" then loop ()
      else if trimmed = "exit" || trimmed = "quit" then (
        print_endline "Goodbye!";
        exit 0)
      else
        try
          let lexer = Lexer.new_lexer trimmed in
          let tokens = Lexer.tokens lexer in
          let ast = Parser.parse tokens in
          let _ = Interpreter.eval_program state ast in
          loop ()
        with
        | Failure msg ->
            Printf.printf "Error: %s\n" msg;
            loop ()
        | e ->
            Printf.printf "Error: %s\n" (Printexc.to_string e);
            loop ()
    with End_of_file ->
      print_endline "\nGoodbye!";
      exit 0
  in
  loop ()

let () = repl ()
