{
open JavaParser
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
  | comment? eof
      { EOF }
  | "true"
      { TRUE ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "false"
      { FALSE ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "LEFT"
      { LEFT ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "RIGHT"
      { RIGHT ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "AHEAD"
      { AHEAD ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "HERE"
      { HERE ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "NORTH"
      { NORTH ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "SOUTH"
      { SOUTH ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "EAST"
      { EAST ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "WEST"
      { WEST ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "if"
      { IF ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "else"
      { ELSE ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "while"
      { WHILE ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "new"
      { NEW ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "method"
      { METHOD ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "&&"
      { AND ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "||"
      { OR ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "!"
      { NOT ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "="
      { EQ ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | ";"
      { SEMICOLON ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | ","
      { COMMA ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | "."
      { DOT ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | '('
      { LPAREN ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | ')'
      { RPAREN ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | '{'
      { LBRACKET ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | '}'
      { RBRACKET ({ lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }, (Lexing.lexeme lexbuf)) }
  | int_constant as i
    { INT ((int_of_string i), { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }) }
  | id as i
    { ID (i, { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) }) }
  | _ {
      raise (Exceptions.LexingException {
          pos = {
            lnum = LexingUtils.get_lnum lexbuf;
            cnum = LexingUtils.get_cnum lexbuf;
          };
          exception_type = "error";
          message = "Illegal character: " ^ Lexing.lexeme lexbuf
        })
    }
and token_comment = parse
  | ml_comment_end { token lexbuf }
  | newline { LexingUtils.next_n_lines 1 lexbuf; token_comment lexbuf }
  | _ { token_comment lexbuf }
