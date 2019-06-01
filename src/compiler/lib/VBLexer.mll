{
open VBLexerState
open VBParser
open Lexing

exception Error of {
    message : string;
    lnum : int;
  }

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
          NEWLINE (LexingUtils.get_lnum lexbuf)
        end else EOF
      }
  | (whitespace* comment? newline)* whitespace* comment? "@@\n" {
      if (not (state.emitted_eof_nl)) then begin
        state.emitted_eof_nl <- true;
        lexbuf.lex_curr_pos <- lexbuf.lex_curr_pos - 3;
        NEWLINE (LexingUtils.get_lnum lexbuf)
      end else begin
        LexingUtils.reset_lnum lexbuf;
        state.emitted_eof_nl <- false;
        MAIN_METH_SEP
      end
    }
  | ((whitespace* comment? newline)* whitespace* comment?) newline
      {
        let lnum = LexingUtils.get_lnum lexbuf in
        let lines = LexingUtils.count_lines (lexeme lexbuf) in
        LexingUtils.next_n_lines lines lexbuf;
        NEWLINE lnum
      }
  | whitespace+
    { token state lexbuf }
  | "@VB\n"
      { HEADER }
  | d i m
      { DIM (LexingUtils.get_lnum lexbuf) }
  | a s
      { AS (LexingUtils.get_lnum lexbuf) }
  | n e w
      { NEW (LexingUtils.get_lnum lexbuf) }
  | s u b
      { SUB (LexingUtils.get_lnum lexbuf) }
  | w h i l e
      { WHILE (LexingUtils.get_lnum lexbuf) }
  | i f
      { IF (LexingUtils.get_lnum lexbuf) }
  | t h e n
      { THEN (LexingUtils.get_lnum lexbuf) }
  | e l s e i f
      { ELSEIF (LexingUtils.get_lnum lexbuf) }
  | e l s e
      { ELSE (LexingUtils.get_lnum lexbuf) }
  | e n d
      { END (LexingUtils.get_lnum lexbuf) }
  | l e f t
      { LEFT (LexingUtils.get_lnum lexbuf) }
  | r i g h t
      { RIGHT (LexingUtils.get_lnum lexbuf) }
  | a h e a d
      { AHEAD (LexingUtils.get_lnum lexbuf) }
  | h e r e
      { HERE (LexingUtils.get_lnum lexbuf) }
  | n o r t h
      { NORTH (LexingUtils.get_lnum lexbuf) }
  | e a s t
      { EAST (LexingUtils.get_lnum lexbuf) }
  | s o u t h
      { SOUTH (LexingUtils.get_lnum lexbuf) }
  | w e s t
      { WEST (LexingUtils.get_lnum lexbuf) }
  | t r u e
      { TRUE (LexingUtils.get_lnum lexbuf) }
  | f a l s e
      { FALSE (LexingUtils.get_lnum lexbuf) }
  | a n d
      { AND (LexingUtils.get_lnum lexbuf) }
  | o r
      { OR (LexingUtils.get_lnum lexbuf) }
  | n o t
      { NOT (LexingUtils.get_lnum lexbuf) }
  | j e r o o
      { ID ("Jeroo", (LexingUtils.get_lnum lexbuf)) }
  | h a s f l o w e r
      { ID ("hasFlower", (LexingUtils.get_lnum lexbuf)) }
  | i s f a c i n g
      { ID ("isFacing", (LexingUtils.get_lnum lexbuf)) }
  | i s f l o w e r
      { ID ("isFlower", (LexingUtils.get_lnum lexbuf)) }
  | i s j e r o o
      { ID ("isJeroo", (LexingUtils.get_lnum lexbuf)) }
  | i s n e t
      { ID ("isNet", (LexingUtils.get_lnum lexbuf)) }
  | i s w a t e r
      {ID ("isWater", (LexingUtils.get_lnum lexbuf)) }
  | i s c l e a r
      {ID ("isClear", (LexingUtils.get_lnum lexbuf)) }
  | '='
      { EQ (LexingUtils.get_lnum lexbuf)}
  | '('
      { LPAREN (LexingUtils.get_lnum lexbuf)}
  | ')'
      { RPAREN (LexingUtils.get_lnum lexbuf)}
  | ','
      { COMMA (LexingUtils.get_lnum lexbuf)}
  | '.'
      { DOT (LexingUtils.get_lnum lexbuf) }
  | int_constant as i
    { INT ((int_of_string i), (LexingUtils.get_lnum lexbuf)) }
  | identifier as id
    { ID ((String.lowercase_ascii id), (LexingUtils.get_lnum lexbuf)) }
  | _ { raise (Error {
        message = "Illegal character: " ^ Lexing.lexeme lexbuf;
        lnum = LexingUtils.get_lnum lexbuf
      })}
