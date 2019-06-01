{
open JavaParser

exception Error of {
    message : string;
    lnum : int;
  }
}

let digit = ['0'-'9']
let nonzerodigit = ['1'-'9']

let id = ['a'-'z' 'A'-'Z' '_']['a'-'z' 'A'-'Z' '0'-'9' '_']*
let int_constant = ['+' '-']? (digit | (nonzerodigit digit+))

let comment = "//" [^ '\n' '\r']*
let ml_comment_start = "/*"
let ml_comment_end = "*/"

let whitespace = [' ' '\t']
let newline = ('\n' | "\r\n")

rule token = parse
  | whitespace+
    { token lexbuf }
  | comment newline
      { LexingUtils.next_n_lines 1 lexbuf; token lexbuf }
  | newline
      { LexingUtils.next_n_lines 1 lexbuf; token lexbuf }
  | ml_comment_start
      { token_comment lexbuf }
  | comment? "@@\n"
      { LexingUtils.reset_lnum lexbuf; MAIN_METH_SEP }
  | comment? eof
      { EOF }
  | "@Java\n"
      { HEADER }
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
  | int_constant as i
    { INT ((int_of_string i), (LexingUtils.get_lnum lexbuf)) }
  | id as i
    { ID (i, (LexingUtils.get_lnum lexbuf)) }
  | _ { raise (Error {
        message = "Illegal character: " ^ Lexing.lexeme lexbuf;
        lnum = LexingUtils.get_lnum lexbuf
      })}
and token_comment = parse
  | ml_comment_end { token lexbuf }
  | newline { LexingUtils.next_n_lines 1 lexbuf; token_comment lexbuf }
  | _ { token_comment lexbuf }
