{
open VBLexerState
open VBParser
open Lexing
}

let whitespace = [' ' '\t']
let newline = ('\n' | "\r\n")
let comment = "'" [^ '\n' '\r']*

let nonzerodigit = ['1'-'9']
let digit = ['0'-'9']
let letter = ['a'-'z' 'A'-'Z' '_']

(* VB is case insensitive *)
let a = 'a' | 'A'
let b = 'b' | 'B'
let c = 'c' | 'C'
let d = 'd' | 'D'
let e = 'e' | 'E'
let f = 'f' | 'F'
let g = 'g' | 'G'
let h = 'h' | 'H'
let i = 'i' | 'I'
let j = 'j' | 'J'
let k = 'k' | 'K'
let l = 'l' | 'L'
let m = 'm' | 'M'
let n = 'n' | 'N'
let o = 'o' | 'O'
let p = 'p' | 'P'
let q = 'q' | 'Q'
let r = 'r' | 'R'
let s = 's' | 'S'
let t = 't' | 'T'
let u = 'u' | 'U'
let v = 'v' | 'V'
let w = 'w' | 'W'
let x = 'x' | 'X'
let y = 'y' | 'Y'
let z = 'z' | 'Z'

let identifier = ['a'-'z' 'A'-'Z' '_']['a'-'z' 'A'-'Z' '0'-'9' '_']*
let int_constant = ['-' '+']? (digit | (nonzerodigit digit+))

rule token state = parse
  | (whitespace* comment? newline)* whitespace* comment? eof
      {
        if (not (state.emitted_eof_nl)) then begin
          state.emitted_eof_nl <- true;
          lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with
                                 pos_cnum = lexbuf.lex_curr_p.pos_cnum - 1 };
          NEWLINE { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }
        end else EOF
      }
  | ((whitespace* comment? newline)* whitespace* comment?) newline
      {
        let lnum = LexingUtils.get_lnum lexbuf in
        let lines = LexingUtils.count_lines (lexeme lexbuf) in
        LexingUtils.next_n_lines lines lexbuf;
        NEWLINE { lnum; cnum = LexingUtils.get_cnum lexbuf }
      }
  | whitespace+
    { token state lexbuf }
  | d i m
      { DIM ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | a s
      { AS ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | n e w
      { NEW ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | s u b
      { SUB ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | w h i l e
      { WHILE ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | i f
      { IF ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | t h e n
      { THEN ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | e l s e i f
      { ELSEIF ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | e l s e
      { ELSE ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | e n d whitespace+ s u b
      { ENDSUB ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | e n d whitespace+ i f
      { ENDIF ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | e n d whitespace w h i l e
      { ENDWHILE ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | l e f t
      { LEFT ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | r i g h t
      { RIGHT ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | a h e a d
      { AHEAD ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | h e r e
      { HERE ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | n o r t h
      { NORTH ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | e a s t
      { EAST ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | s o u t h
      { SOUTH ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | w e s t
      { WEST ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | t r u e
      { TRUE ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | f a l s e
      { FALSE ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | a n d
      { AND ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | o r
      { OR ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | n o t
      { NOT ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | j e r o o
      { ID ("Jeroo", { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }) }
  | h a s f l o w e r
      { ID ("hasFlower", { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }) }
  | i s f a c i n g
      { ID ("isFacing", { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }) }
  | i s f l o w e r
      { ID ("isFlower", { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }) }
  | i s j e r o o
      { ID ("isJeroo", { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }) }
  | i s n e t
      { ID ("isNet", { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }) }
  | i s w a t e r
      {ID ("isWater", { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }) }
  | i s c l e a r
      {ID ("isClear", { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }) }
  | '='
      { EQ ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | '('
      { LPAREN ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | ')'
      { RPAREN ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | ','
      { COMMA ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | '.'
      { DOT ( { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | int_constant as i
    { INT (int_of_string i, { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf } ) }
  | identifier as id
    { ID (String.lowercase_ascii id, { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf } ) }
  | _ {
      raise (Exceptions.LexingException {
          pos = {
            lnum = LexingUtils.get_lnum lexbuf;
            cnum = LexingUtils.get_cnum lexbuf;
          };
          exception_type = "error";
          message = "Illegal character: " ^ Lexing.lexeme lexbuf;
        })
    }
