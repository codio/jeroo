{
open JavaParser
open Lexing

exception Error of string
}

let digit = ['0'-'9']
let letter = ['a'-'z' 'A'-'Z' '_']

let id = letter (letter | digit)*
let int_constant = '-'? digit+

let comment = "//" [^'\n']* '\n'
let ml_comment = "/*" [^'*']* [^'/']* "*/"

let whitespace = ['\r' ' ' '\t']+
let newline = '\n'

rule token = parse
| whitespace
  { token lexbuf }
| newline
  { new_line lexbuf; token lexbuf }
| comment
  { new_line lexbuf; token lexbuf }
| ml_comment as text
  { let num_lines =
      text
      |> String.to_seq
      |> Seq.fold_left (fun accum ele -> if ele = '\n' then 1 + accum else accum) 0
    in LexingUtils.next_n_lines num_lines lexbuf; token lexbuf }
| "@Java\n"
  { HEADER }
| "@@\n"
  { LexingUtils.reset_lnum lexbuf; MAIN_METH_SEP }
| int_constant as i
  { INT ((int_of_string i), (LexingUtils.get_lnum lexbuf)) }
| "true"
  { TRUE (LexingUtils.get_lnum lexbuf) }
| "false"
  { FALSE (LexingUtils.get_lnum lexbuf) }
| "LEFT"
  { LEFT (LexingUtils.get_lnum lexbuf) }
| "RIGHT"
  { RIGHT (LexingUtils.get_lnum lexbuf) }
| "AHEAD"
  { AHEAD (LexingUtils.get_lnum lexbuf) }
| "HERE"
  { HERE (LexingUtils.get_lnum lexbuf) }
| "NORTH"
  { NORTH (LexingUtils.get_lnum lexbuf) }
| "SOUTH"
  { SOUTH (LexingUtils.get_lnum lexbuf) }
| "EAST"
  { EAST (LexingUtils.get_lnum lexbuf) }
| "WEST"
  { WEST (LexingUtils.get_lnum lexbuf) }
| "if"
  { IF (LexingUtils.get_lnum lexbuf) }
| "else"
  { ELSE (LexingUtils.get_lnum lexbuf) }
| "while"
  { WHILE (LexingUtils.get_lnum lexbuf) }
| "new"
  { NEW (LexingUtils.get_lnum lexbuf) }
| "method"
  { METHOD (LexingUtils.get_lnum lexbuf) }
| id as i
  { ID (i, (LexingUtils.get_lnum lexbuf)) }
| "&&"
  { AND (LexingUtils.get_lnum lexbuf) }
| "||"
  { OR (LexingUtils.get_lnum lexbuf) }
| "!"
  { NOT (LexingUtils.get_lnum lexbuf) }
| "="
  { EQ (LexingUtils.get_lnum lexbuf) }
| ";"
  { SEMICOLON (LexingUtils.get_lnum lexbuf) }
| ","
  { COMMA (LexingUtils.get_lnum lexbuf) }
| "."
  { DOT (LexingUtils.get_lnum lexbuf) }
| '('
  { LPAREN (LexingUtils.get_lnum lexbuf) }
| ')'
  { RPAREN (LexingUtils.get_lnum lexbuf) }
| '{'
  { LBRACKET (LexingUtils.get_lnum lexbuf) }
| '}'
  { RBRACKET (LexingUtils.get_lnum lexbuf) }
| eof
  { EOF }
| _
  { raise (Error (Printf.sprintf "At offset %d: unexpected character.\n" (Lexing.lexeme_start lexbuf))) }
