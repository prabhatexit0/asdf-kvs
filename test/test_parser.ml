let test_parser () =
  let test_case input expected_ast =
    Printf.printf "\n--- Testing: %s ---\n" input;
    let lexer = Lexer.new_lexer input in
    let tokens = Lexer.tokens lexer in
    Printf.printf "Tokens: ";
    Lexer.print_tokens tokens;
    let ast = Parser.parse tokens in
    Printf.printf "AST: ";
    Parser.print_program ast;
    assert (ast = expected_ast);
    Printf.printf "✓ Test passed!\n"
  in

  print_endline "\n=== Running Parser Tests ===\n";

  test_case "create \"mystore\""
    [ Parser.Create (Parser.StringLiteral "mystore") ];

  test_case "select mystore" [ Parser.Select (Parser.Name "mystore") ];

  test_case "set \"key\" \"value\""
    [ Parser.Set (Parser.StringLiteral "key", Parser.StringLiteral "value") ];

  test_case "get \"key\"" [ Parser.Get (Parser.StringLiteral "key") ];

  test_case "set get \"x\" \"y\""
    [
      Parser.Set
        (Parser.Get (Parser.StringLiteral "x"), Parser.StringLiteral "y");
    ];

  test_case "dump \"mystore\"" [ Parser.Dump (Parser.StringLiteral "mystore") ];

  test_case "save \"file.db\"" [ Parser.Save (Parser.StringLiteral "file.db") ];

  test_case "load \"file.db\"" [ Parser.Load (Parser.StringLiteral "file.db") ];

  test_case "create \"store1\"; select \"store1\""
    [
      Parser.Create (Parser.StringLiteral "store1");
      Parser.Select (Parser.StringLiteral "store1");
    ];

  test_case "set get get \"x\" \"final\""
    [
      Parser.Set
        ( Parser.Get (Parser.Get (Parser.StringLiteral "x")),
          Parser.StringLiteral "final" );
    ];

  print_endline "\n=== All Parser Tests Passed! ===\n"

let () = test_parser ()
