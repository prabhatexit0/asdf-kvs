open Asdf_kvs

let main () =
  print_endline "=== asdf-kvs: Key-Value Store ===\n";

  let program_text =
    "create \"users\"; use \"users\"; set \"alice\" string \"admin\"; set \
     \"bob\" string \"user\"; set \"age\" i32 \"30\"; get \"alice\"; dump \
     \"users\""
  in

  print_endline "Running demo program:\n";
  print_endline program_text;
  print_endline "";

  let lexer = Lexer.new_lexer program_text in
  let tokens = Lexer.tokens lexer in
  let ast = Parser.parse tokens in
  let state = Interpreter.create_state () in
  let _ = Interpreter.eval_program state ast in

  print_endline "\n=== Demo completed! ==="

let () = main ()
