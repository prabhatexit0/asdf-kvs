let test_lexer () =
  let test_case input expected_tokens =
    let lexer = Lexer.new_lexer input in
    let tokens = Lexer.tokens lexer in
    Lexer.print_tokens tokens;
    assert (tokens = expected_tokens);
    Printf.printf "✓ Test passed for input: %s\n" input
  in

  print_endline "\n=== Running Lexer Tests ===\n";

  (* Define your test cases here *)
  test_case "create asdf" [ Lexer.Tok_Create; Lexer.Tok_Name "asdf" ];
  test_case "select item" [ Lexer.Tok_Select; Lexer.Tok_Name "item" ];
  test_case "set key value"
    [ Lexer.Tok_Set; Lexer.Tok_Name "key"; Lexer.Tok_Name "value" ];
  test_case "get key" [ Lexer.Tok_Get; Lexer.Tok_Name "key" ];
  test_case "dump" [ Lexer.Tok_Dump ];
  test_case "load \"file.txt\""
    [ Lexer.Tok_Load; Lexer.Tok_StringLiteral "file.txt" ];
  test_case "drop item" [ Lexer.Tok_Drop; Lexer.Tok_Name "item" ];
  test_case "unselect item" [ Lexer.Tok_Unselect; Lexer.Tok_Name "item" ];
  test_case "()" [ Lexer.Tok_LParen; Lexer.Tok_RParen ];
  test_case ";" [ Lexer.Tok_Semi ];

  print_endline "\n=== All Lexer Tests Passed! ===\n"

let () = test_lexer ()
