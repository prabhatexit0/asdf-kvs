open Unix

type server_state = { state : Interpreter.state; mutable clients : int }

let create_server_state () =
  { state = Interpreter.create_state (); clients = 0 }

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

let send_response sock msg =
  let msg_with_newline = msg ^ "\n" in
  let bytes = Bytes.of_string msg_with_newline in
  let _ = send sock bytes 0 (Bytes.length bytes) [] in
  ()

let handle_command server_state command =
  try
    let lexer = Lexer.new_lexer command in
    let tokens = Lexer.tokens lexer in
    let ast = Parser.parse tokens in
    let results = Interpreter.eval_program server_state.state ast in
    let result_strs = List.map Interpreter.value_to_string results in
    "OK: " ^ String.concat "; " result_strs
  with
  | Failure msg -> "ERROR: " ^ msg
  | e -> "ERROR: " ^ Printexc.to_string e

let handle_client server_state client_sock client_id =
  Printf.printf "[Server] Client #%d connected\n%!" client_id;
  send_response client_sock
    (Printf.sprintf "Welcome to asdf-kvs server! (Client #%d)" client_id);

  let rec loop () =
    match read_line_from_socket client_sock with
    | None ->
        Printf.printf "[Server] Client #%d disconnected\n%!" client_id;
        close client_sock
    | Some line ->
        let trimmed = String.trim line in
        if trimmed = "" then loop ()
        else if trimmed = "exit" || trimmed = "quit" then (
          send_response client_sock "Goodbye!";
          Printf.printf "[Server] Client #%d disconnected (exit)\n%!" client_id;
          close client_sock)
        else (
          Printf.printf "[Server] Client #%d: %s\n%!" client_id trimmed;
          let response = handle_command server_state trimmed in
          send_response client_sock response;
          loop ())
  in
  loop ()

let start_server host port =
  let server_state = create_server_state () in
  let addr = inet_addr_of_string host in
  let sock_addr = ADDR_INET (addr, port) in

  let server_sock = socket PF_INET SOCK_STREAM 0 in
  setsockopt server_sock SO_REUSEADDR true;
  bind server_sock sock_addr;
  listen server_sock 10;

  Printf.printf "🚀 asdf-kvs TCP Server started on %s:%d\n%!" host port;
  Printf.printf "Waiting for client connections...\n\n%!";

  let rec accept_loop () =
    let client_sock, client_addr = accept server_sock in
    server_state.clients <- server_state.clients + 1;
    let client_id = server_state.clients in

    match client_addr with
    | ADDR_INET (addr, port) ->
        Printf.printf "[Server] New connection from %s:%d\n%!"
          (string_of_inet_addr addr) port;
        let _ =
          Thread.create (handle_client server_state client_sock) client_id
        in
        accept_loop ()
    | _ ->
        Printf.printf "[Server] Unknown connection type\n%!";
        close client_sock;
        accept_loop ()
  in

  try accept_loop ()
  with e ->
    Printf.printf "Server error: %s\n%!" (Printexc.to_string e);
    close server_sock

let () =
  let host = "127.0.0.1" in
  let port = 9090 in
  start_server host port
