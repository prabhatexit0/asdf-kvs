type token =
  | Tok_Create
  | Tok_Select
  | Tok_Unselect
  | Tok_Drop
  | Tok_Set
  | Tok_Get
  | Tok_Save
  | Tok_Load
  | Tok_Dump
  | Tok_LParen
  | Tok_RParen
  | Tok_Semi
  | Tok_End
  | Tok_Name of string
  | Tok_StringLiteral of string

let token_to_string = function
  | Tok_Create -> "create"
  | Tok_Select -> "select"
  | Tok_Unselect -> "unselect"
  | Tok_Drop -> "drop"
  | Tok_Set -> "set"
  | Tok_Get -> "get"
  | Tok_Save -> "save"
  | Tok_Load -> "load"
  | Tok_Dump -> "dump"
  | Tok_LParen -> "("
  | Tok_RParen -> ")"
  | Tok_Semi -> ";"
  | Tok_End -> "end"
  | Tok_Name s -> Printf.sprintf "name(%s)" s
  | Tok_StringLiteral s -> Printf.sprintf "string_literal(%s)" s

type lexer = { input : string; mutable pos : int; mutable ch : char }

let new_lexer input_string =
  if String.length input_string = 0 then failwith "Empty program";

  let lexer =
    { input = input_string; pos = 0; ch = String.get input_string 0 }
  in
  lexer

let move lexer =
  lexer.pos <- lexer.pos + 1;
  (* Update pos directly *)
  if lexer.pos < String.length lexer.input then
    lexer.ch <- String.get lexer.input lexer.pos (* Update ch directly *)
  else lexer.ch <- '\x00'

let get_identifier lexer =
  let rec aux acc =
    match lexer.ch with
    | ' ' | '\n' | ';' | '\x00' -> acc
    | ch ->
        move lexer;
        aux (acc ^ String.make 1 ch)
  in
  let ident = aux "" in
  ident

let collect_string lexer =
  move lexer;
  let rec aux acc =
    match lexer.ch with
    | '"' -> acc
    | ch ->
        move lexer;
        aux (acc ^ String.make 1 ch)
  in
  aux ""

let handle_whitespace lexer f =
  move lexer;
  f ()

let handle_identifier lexer =
  let ident = get_identifier lexer in
  match ident with
  | "create" -> Tok_Create
  | "select" -> Tok_Select
  | "unselect" -> Tok_Unselect
  | "drop" -> Tok_Drop
  | "set" -> Tok_Set
  | "get" -> Tok_Get
  | "save" -> Tok_Save
  | "load" -> Tok_Load
  | "dump" -> Tok_Dump
  | name -> Tok_Name name

let next_token lexer =
  let rec aux () =
    if lexer.pos >= String.length lexer.input then Tok_End
    else
      match lexer.ch with
      | ' ' | '\n' -> handle_whitespace lexer aux
      | '(' -> Tok_LParen
      | ')' -> Tok_RParen
      | ';' -> Tok_Semi
      | '"' ->
          let string_literal = collect_string lexer in
          Tok_StringLiteral string_literal
      | _ -> handle_identifier lexer
  in
  aux ()

let tokens lexer =
  let rec aux acc =
    let token = next_token lexer in
    match token with
    | Tok_End -> acc
    | tok ->
        move lexer;
        aux (tok :: acc)
  in
  List.rev @@ aux []

let print_tokens tokens =
  let rec aux tokens =
    match tokens with
    | [] -> failwith "No tokens"
    | [ tok ] -> Printf.printf "tok (<%s>)\n" (token_to_string tok)
    | tok :: rest ->
        Printf.printf "tok (<%s>) " (token_to_string tok);
        aux rest
  in
  aux tokens
