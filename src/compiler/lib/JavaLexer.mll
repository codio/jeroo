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
      { TRUE { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "false"
      { FALSE { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "LEFT"
      { LEFT { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "RIGHT"
      { RIGHT { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "AHEAD"
      { AHEAD { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "HERE"
      { HERE { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "NORTH"
      { NORTH { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "SOUTH"
      { SOUTH { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "EAST"
      { EAST { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "WEST"
      { WEST { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "if"
      { IF { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "else"
      { ELSE { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "while"
      { WHILE { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "new"
      { NEW { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "method"
      { METHOD { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "&&"
      { AND { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "||"
      { OR { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "!"
      { NOT { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "="
      { EQ { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | ";"
      { SEMICOLON { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | ","
      { COMMA { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | "."
      { DOT { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | '('
      { LPAREN { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | ')'
      { RPAREN { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | '{'
      { LBRACKET { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
  | '}'
      { RBRACKET { lnum = (LexingUtils.get_lnum lexbuf); cnum = (LexingUtils.get_cnum lexbuf) } }
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
