open Asdf_kvs

let run_test description program_text =
  Printf.printf "\n=== Test: %s ===\n" description;
  Printf.printf "Input: %s\n\n" program_text;
  try
    let lexer = Lexer.new_lexer program_text in
    let tokens = Lexer.tokens lexer in
    let ast = Parser.parse tokens in
    let state = Interpreter.create_state () in
    let _ = Interpreter.eval_program state ast in
    Printf.printf "✓ Test passed!\n"
  with Failure msg -> Printf.printf "✗ Test failed: %s\n" msg

let test_interpreter () =
  print_endline "\n=== Running Interpreter Tests ===\n";

  run_test "Create a store" "create \"users\"";

  run_test "Create and select a store" "create \"products\"; use \"products\"";

  run_test "Create, select, and set a key-value"
    "create \"store1\"; use \"store1\"; set \"key1\" string \"value1\"";

  run_test "Create, select, set, and get"
    "create \"mystore\"; use \"mystore\"; set \"name\" string \"Alice\"; get \
     \"name\"";

  run_test "Multiple key-value pairs"
    "create \"db\"; use \"db\"; set \"a\" string \"1\"; set \"b\" string \
     \"2\"; set \"c\" string \"3\"";

  run_test "Nested get in set"
    "create \"s\"; use \"s\"; set \"x\" string \"hello\"; set \"y\" string get \
     \"x\"; get \"y\"";

  run_test "Dump empty store" "create \"empty\"; dump \"empty\"";

  run_test "Dump store with data"
    "create \"data\"; use \"data\"; set \"foo\" string \"bar\"; set \"baz\" \
     string \"qux\"; dump \"data\"";

  run_test "Drop a store" "create \"temp\"; drop \"temp\"";

  run_test "Unselect a store" "create \"test\"; use \"test\"; unselect \"test\"";

  run_test "Multiple stores"
    "create \"store1\"; create \"store2\"; use \"store1\"; set \"k1\" string \
     \"v1\"; use \"store2\"; set \"k2\" string \"v2\"";

  run_test "Save operation (stub)" "create \"persist\"; save \"backup.db\"";

  run_test "Load operation (stub)" "load \"backup.db\"";

  print_endline "\n=== Error Handling Tests ===\n";

  run_test "Set without selecting store (should fail)"
    "create \"s\"; set \"key\" string \"value\"";

  run_test "Get without selecting store (should fail)"
    "create \"s\"; get \"key\"";

  run_test "Get non-existent key (should fail)"
    "create \"s\"; use \"s\"; get \"missing\"";

  run_test "Select non-existent store (should fail)" "use \"nonexistent\"";

  run_test "Drop non-existent store (should fail)" "drop \"nonexistent\"";

  run_test "Create duplicate store (should fail)"
    "create \"dup\"; create \"dup\"";

  print_endline "\n=== All Interpreter Tests Completed! ===\n"

let () = test_interpreter ()
