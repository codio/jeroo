{
open Parser
exception Error of string
}

let digit = ['0'-'9']
let letter = ['a'-'z' 'A'-'Z' '_']

let id = letter (letter | digit)*
let int_constant = digit+

let comment = "//" [^'\n']* '\n'
let ml_comment = "/*" [^'*']* [^'/']* "*/"

let whitespace = ['\n''\r'' ' '\t']+

rule token = parse
| whitespace
  { token lexbuf }
| comment
  { token lexbuf }
| ml_comment
  { token lexbuf }
| int_constant as i
  { INT (int_of_string i) }
| "true"
  { TRUE }
| "false"
  { FALSE }
| "LEFT"
  { LEFT }
| "RIGHT"
  { RIGHT }
| "AHEAD"
  { AHEAD }
| "HERE"
  { HERE }
| "NORTH"
  { NORTH }
| "SOUTH"
  { SOUTH }
| "EAST"
  { EAST }
| "WEST"
  { WEST }
| "if"
  { IF }
| "else"
  { ELSE }
| "while"
  { WHILE }
| "new"
  { NEW }
| "method"
  { METHOD }
| id as i
  { ID i }
| "&&"
  { AND }
| "||"
  { OR }
| "!"
  { NOT }
| "="
  { EQ }
| ";"
  { SEMICOLON }
| ","
  { COMMA }
| "."
  { DOT }
| '('
  { LPAREN }
| ')'
  { RPAREN }
| '{'
  { LBRACKET }
| '}'
  { RBRACKET }
| eof
  { EOF }
| _
  { raise (Error (Printf.sprintf "At offset %d: unexpected character.\n" (Lexing.lexeme_start lexbuf))) }
