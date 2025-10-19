open Unix

let read_line_from_socket sock =
  let buffer = Buffer.create 256 in
  let bytes = Bytes.create 1 in
  let rec read_char () =
    match recv sock bytes 0 1 [] with
    | 0 -> None
    | _ ->
        let ch = Bytes.get bytes 0 in
        if ch = '\n' then Some (Buffer.contents buffer)
        else (
          Buffer.add_char buffer ch;
          read_char ())
  in
  read_char ()

let send_message sock msg =
  let msg_with_newline = msg ^ "\n" in
  let bytes = Bytes.of_string msg_with_newline in
  let _ = send sock bytes 0 (Bytes.length bytes) [] in
  ()

let print_banner () =
  print_endline "╔════════════════════════════════════════╗";
  print_endline "║  🔑  asdf-kvs TCP Client               ║";
  print_endline "║     Connected to Remote Server         ║";
  print_endline "╚════════════════════════════════════════╝";
  print_endline "";
  print_endline "Commands:";
  print_endline "  create <name>       - Create a new store";
  print_endline "  use <name>          - Select a store";
  print_endline "  set <key> <type> <value> - Set a key-value pair";
  print_endline "  get <key>           - Get a value";
  print_endline "  dump <store>        - Show all keys in store";
  print_endline "  exit                - Disconnect from server";
  print_endline ""

let start_client host port =
  let addr = inet_addr_of_string host in
  let sock_addr = ADDR_INET (addr, port) in

  let sock = socket PF_INET SOCK_STREAM 0 in

  try
    connect sock sock_addr;
    Printf.printf "Connected to server at %s:%d\n\n" host port;

    match read_line_from_socket sock with
    | Some welcome_msg ->
        Printf.printf "%s\n\n" welcome_msg;
        print_banner ();

        let rec loop () =
          print_string "❯ ";
          flush Stdlib.stdout;
          let line = Stdlib.read_line () in
          let trimmed = String.trim line in
          if trimmed = "" then loop ()
          else if trimmed = "exit" || trimmed = "quit" then (
            send_message sock "exit";
            match read_line_from_socket sock with
            | Some response -> Printf.printf "%s\n" response
            | None ->
                ();
                close sock;
                print_endline "\n🐸 Goodbye! Happy coding!")
          else (
            send_message sock trimmed;
            match read_line_from_socket sock with
            | Some response ->
                if String.starts_with ~prefix:"OK: " response then
                  Printf.printf "🐸 %s\n"
                    (String.sub response 4 (String.length response - 4))
                else if String.starts_with ~prefix:"ERROR: " response then
                  Printf.printf "🍂 %s\n"
                    (String.sub response 7 (String.length response - 7))
                else Printf.printf "%s\n" response;
                loop ()
            | None ->
                print_endline "🍂 Connection lost";
                close sock)
        in
        loop ()
    | None ->
        print_endline "Failed to receive welcome message";
        close sock
  with
  | Unix_error (err, fn, arg) ->
      Printf.printf "Connection error: %s in %s(%s)\n" (error_message err) fn
        arg;
      close sock
  | e ->
      Printf.printf "Error: %s\n" (Printexc.to_string e);
      close sock

let () =
  let host = if Array.length Sys.argv > 1 then Sys.argv.(1) else "127.0.0.1" in
  let port =
    if Array.length Sys.argv > 2 then int_of_string Sys.argv.(2) else 9090
  in
  start_client host port
