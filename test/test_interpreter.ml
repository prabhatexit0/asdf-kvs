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

  run_test "Create and select a store"
    "create \"products\"; select \"products\"";

  run_test "Create, select, and set a key-value"
    "create \"store1\"; select \"store1\"; set \"key1\" \"value1\"";

  run_test "Create, select, set, and get"
    "create \"mystore\"; select \"mystore\"; set \"name\" \"Alice\"; get \
     \"name\"";

  run_test "Multiple key-value pairs"
    "create \"db\"; select \"db\"; set \"a\" \"1\"; set \"b\" \"2\"; set \"c\" \
     \"3\"";

  run_test "Nested get in set"
    "create \"s\"; select \"s\"; set \"x\" \"hello\"; set \"y\" get \"x\"; get \
     \"y\"";

  run_test "Dump empty store" "create \"empty\"; dump \"empty\"";

  run_test "Dump store with data"
    "create \"data\"; select \"data\"; set \"foo\" \"bar\"; set \"baz\" \
     \"qux\"; dump \"data\"";

  run_test "Drop a store" "create \"temp\"; drop \"temp\"";

  run_test "Unselect a store"
    "create \"test\"; select \"test\"; unselect \"test\"";

  run_test "Multiple stores"
    "create \"store1\"; create \"store2\"; select \"store1\"; set \"k1\" \
     \"v1\"; select \"store2\"; set \"k2\" \"v2\"";

  run_test "Save operation (stub)" "create \"persist\"; save \"backup.db\"";

  run_test "Load operation (stub)" "load \"backup.db\"";

  print_endline "\n=== Error Handling Tests ===\n";

  run_test "Set without selecting store (should fail)"
    "create \"s\"; set \"key\" \"value\"";

  run_test "Get without selecting store (should fail)"
    "create \"s\"; get \"key\"";

  run_test "Get non-existent key (should fail)"
    "create \"s\"; select \"s\"; get \"missing\"";

  run_test "Select non-existent store (should fail)" "select \"nonexistent\"";

  run_test "Drop non-existent store (should fail)" "drop \"nonexistent\"";

  run_test "Create duplicate store (should fail)"
    "create \"dup\"; create \"dup\"";

  print_endline "\n=== All Interpreter Tests Completed! ===\n"

let () = test_interpreter ()
