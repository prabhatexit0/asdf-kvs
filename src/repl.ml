open Asdf_kvs

module Colors = struct
  let reset = "\027[0m"
  let bold = "\027[1m"
  let dim = "\027[2m"
  let red = "\027[31m"
  let yellow = "\027[33m"
  let cyan = "\027[36m"
  let white = "\027[37m"
  let bright_green = "\027[92m"
  let bright_blue = "\027[94m"
  let bright_magenta = "\027[95m"
  let bright_cyan = "\027[96m"
end

let clear_screen () =
  print_string "\027[2J\027[H";
  flush stdout

let print_welcome () =
  print_endline
    (Colors.bold ^ Colors.bright_blue
   ^ "╔════════════════════════════════════════╗" ^ Colors.reset);
  print_endline
    (Colors.bold ^ Colors.bright_blue ^ "║  " ^ Colors.bright_green
   ^ "🔑  asdf-kvs REPL" ^ Colors.bright_blue ^ "                     ║"
   ^ Colors.reset);
  print_endline
    (Colors.bold ^ Colors.bright_blue ^ "║     " ^ Colors.white
   ^ "Interactive Key-Value Store" ^ Colors.bright_blue ^ "        ║"
   ^ Colors.reset);
  print_endline
    (Colors.bold ^ Colors.bright_blue
   ^ "╚════════════════════════════════════════╝" ^ Colors.reset);
  print_endline "";
  print_endline (Colors.cyan ^ "Commands:" ^ Colors.reset);
  print_endline
    (Colors.dim ^ "  " ^ Colors.bright_magenta ^ "create" ^ Colors.reset
   ^ Colors.dim ^ " <name>       - Create a new store" ^ Colors.reset);
  print_endline
    (Colors.dim ^ "  " ^ Colors.bright_magenta ^ "use" ^ Colors.reset
   ^ Colors.dim ^ " <name>          - Select a store" ^ Colors.reset);
  print_endline
    (Colors.dim ^ "  " ^ Colors.bright_magenta ^ "unselect" ^ Colors.reset
   ^ Colors.dim ^ " <name>     - Unselect a store" ^ Colors.reset);
  print_endline
    (Colors.dim ^ "  " ^ Colors.bright_magenta ^ "drop" ^ Colors.reset
   ^ Colors.dim ^ " <name>         - Delete a store" ^ Colors.reset);
  print_endline
    (Colors.dim ^ "  " ^ Colors.bright_magenta ^ "set" ^ Colors.reset
   ^ Colors.dim ^ " <key> <value>   - Set a key-value pair" ^ Colors.reset);
  print_endline
    (Colors.dim ^ "  " ^ Colors.bright_magenta ^ "get" ^ Colors.reset
   ^ Colors.dim ^ " <key>           - Get a value" ^ Colors.reset);
  print_endline
    (Colors.dim ^ "  " ^ Colors.bright_magenta ^ "dump" ^ Colors.reset
   ^ Colors.dim ^ " <store>        - Show all keys in store" ^ Colors.reset);
  print_endline
    (Colors.dim ^ "  " ^ Colors.bright_magenta ^ "save" ^ Colors.reset
   ^ Colors.dim ^ " <file>         - Save store to file (stub)" ^ Colors.reset);
  print_endline
    (Colors.dim ^ "  " ^ Colors.bright_magenta ^ "load" ^ Colors.reset
   ^ Colors.dim ^ " <file>         - Load store from file (stub)" ^ Colors.reset
    );
  print_endline
    (Colors.dim ^ "  " ^ Colors.yellow ^ "cls" ^ Colors.reset ^ Colors.dim
   ^ "                 - Clear screen" ^ Colors.reset);
  print_endline
    (Colors.dim ^ "  " ^ Colors.yellow ^ "exit" ^ Colors.reset ^ Colors.dim
   ^ "                - Exit REPL" ^ Colors.reset);
  print_endline "";
  print_endline
    (Colors.dim ^ "Expressions can be nested: " ^ Colors.bright_magenta ^ "set"
   ^ Colors.reset ^ " " ^ Colors.bright_magenta ^ "get" ^ Colors.reset ^ " "
   ^ Colors.bright_cyan ^ "\"x\"" ^ Colors.reset ^ " " ^ Colors.bright_cyan
   ^ "\"y\"" ^ Colors.reset ^ Colors.dim ^ Colors.reset);
  print_endline
    (Colors.dim ^ "Multiple commands: " ^ Colors.bright_magenta ^ "create"
   ^ Colors.reset ^ " " ^ Colors.bright_cyan ^ "\"s\"" ^ Colors.reset ^ "; "
   ^ Colors.bright_magenta ^ "use" ^ Colors.reset ^ " " ^ Colors.bright_cyan
   ^ "\"s\"" ^ Colors.reset ^ Colors.dim ^ Colors.reset);
  print_endline ""

let repl () =
  print_welcome ();
  let state = Interpreter.create_state () in

  let rec loop () =
    try
      print_string
        (Colors.bold ^ Colors.bright_green ^ "❯ " ^ Colors.reset
       ^ Colors.bright_blue);
      flush stdout;
      let line = read_line () in
      print_string Colors.reset;
      let trimmed = String.trim line in

      if trimmed = "" then loop ()
      else if trimmed = "exit" || trimmed = "quit" then (
        print_endline
          (Colors.bright_green ^ "🐸 Goodbye! " ^ Colors.dim ^ "Happy coding!"
         ^ Colors.reset);
        exit 0)
      else if trimmed = "cls" || trimmed = "clear" then (
        clear_screen ();
        print_welcome ();
        loop ())
      else
        try
          let lexer = Lexer.new_lexer trimmed in
          let tokens = Lexer.tokens lexer in
          let ast = Parser.parse tokens in
          let _ = Interpreter.eval_program state ast in
          print_endline (Colors.bright_green ^ "🐸 Success!" ^ Colors.reset);
          loop ()
        with
        | Failure msg ->
            print_endline
              (Colors.red ^ "🍂 Error: " ^ Colors.reset ^ Colors.yellow ^ msg
             ^ Colors.reset);
            loop ()
        | e ->
            print_endline
              (Colors.red ^ "🍂 Error: " ^ Colors.reset ^ Colors.yellow
             ^ Printexc.to_string e ^ Colors.reset);
            loop ()
    with End_of_file ->
      print_endline
        (Colors.bright_green ^ "\n🐸 Goodbye! " ^ Colors.dim ^ "Happy coding!"
       ^ Colors.reset);
      exit 0
  in
  loop ()

let () = repl ()
