type data_type = I32 | I64 | F32 | F64 | String

type expr =
  | StringLiteral of string
  | Name of string
  | Create of expr
  | Select of expr
  | Unselect of expr
  | Drop of expr
  | Set of expr * data_type * expr
  | Get of expr
  | Save of expr
  | Load of expr
  | Dump of expr

type program = expr list

let data_type_to_string = function
  | I32 -> "i32"
  | I64 -> "i64"
  | F32 -> "f32"
  | F64 -> "f64"
  | String -> "string"

let rec expr_to_string = function
  | StringLiteral s -> Printf.sprintf "\"%s\"" s
  | Name n -> n
  | Create e -> Printf.sprintf "(CREATE %s)" (expr_to_string e)
  | Select e -> Printf.sprintf "(SELECT %s)" (expr_to_string e)
  | Unselect e -> Printf.sprintf "(UNSELECT %s)" (expr_to_string e)
  | Drop e -> Printf.sprintf "(DROP %s)" (expr_to_string e)
  | Set (key, dtype, value) ->
      Printf.sprintf "(SET %s %s %s)" (expr_to_string key)
        (data_type_to_string dtype)
        (expr_to_string value)
  | Get e -> Printf.sprintf "(GET %s)" (expr_to_string e)
  | Save e -> Printf.sprintf "(SAVE %s)" (expr_to_string e)
  | Load e -> Printf.sprintf "(LOAD %s)" (expr_to_string e)
  | Dump e -> Printf.sprintf "(DUMP %s)" (expr_to_string e)

let print_program program =
  List.iter (fun expr -> Printf.printf "%s\n" (expr_to_string expr)) program

type parser = { tokens : Lexer.token list; mutable pos : int }

let make_parser tokens = { tokens; pos = 0 }

let peek parser =
  if parser.pos < List.length parser.tokens then
    List.nth parser.tokens parser.pos
  else Lexer.Tok_End

let advance parser = parser.pos <- parser.pos + 1

let consume parser =
  let tok = peek parser in
  advance parser;
  tok

let parse_data_type parser =
  match peek parser with
  | Lexer.Tok_I32 ->
      advance parser;
      I32
  | Lexer.Tok_I64 ->
      advance parser;
      I64
  | Lexer.Tok_F32 ->
      advance parser;
      F32
  | Lexer.Tok_F64 ->
      advance parser;
      F64
  | Lexer.Tok_String ->
      advance parser;
      String
  | tok ->
      failwith
        (Printf.sprintf "Expected data type, got: %s"
           (Lexer.token_to_string tok))

let rec parse_expr parser =
  match peek parser with
  | Lexer.Tok_Create ->
      advance parser;
      let arg = parse_expr parser in
      Create arg
  | Lexer.Tok_Use ->
      advance parser;
      let arg = parse_expr parser in
      Select arg
  | Lexer.Tok_Unselect ->
      advance parser;
      let arg = parse_expr parser in
      Unselect arg
  | Lexer.Tok_Drop ->
      advance parser;
      let arg = parse_expr parser in
      Drop arg
  | Lexer.Tok_Set ->
      advance parser;
      let key = parse_expr parser in
      let dtype = parse_data_type parser in
      let value = parse_expr parser in
      Set (key, dtype, value)
  | Lexer.Tok_Get ->
      advance parser;
      let arg = parse_expr parser in
      Get arg
  | Lexer.Tok_Save ->
      advance parser;
      let arg = parse_expr parser in
      Save arg
  | Lexer.Tok_Load ->
      advance parser;
      let arg = parse_expr parser in
      Load arg
  | Lexer.Tok_Dump ->
      advance parser;
      let arg = parse_expr parser in
      Dump arg
  | Lexer.Tok_StringLiteral s ->
      advance parser;
      StringLiteral s
  | Lexer.Tok_Name n ->
      advance parser;
      Name n
  | Lexer.Tok_LParen ->
      advance parser;
      let e = parse_expr parser in
      (match peek parser with
      | Lexer.Tok_RParen -> advance parser
      | _ -> failwith "Expected closing parenthesis");
      e
  | Lexer.Tok_Semi | Lexer.Tok_End -> failwith "Unexpected token in expression"
  | Lexer.Tok_I32 | Lexer.Tok_I64 | Lexer.Tok_F32 | Lexer.Tok_F64
  | Lexer.Tok_String ->
      failwith "Data type tokens cannot be used as expressions"
  | tok ->
      failwith
        (Printf.sprintf "Unexpected token: %s" (Lexer.token_to_string tok))

let parse_program parser =
  let rec aux acc =
    match peek parser with
    | Lexer.Tok_End -> List.rev acc
    | Lexer.Tok_Semi ->
        advance parser;
        aux acc
    | _ ->
        let expr = parse_expr parser in
        aux (expr :: acc)
  in
  aux []

let parse tokens =
  let parser = make_parser tokens in
  parse_program parser
