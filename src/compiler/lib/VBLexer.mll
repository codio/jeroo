{
  open VBParser
  exception Error of string
}

let whitespace = [' ' '\t' '\r']+
let newline = '\n'+
let comment = "'" [^'\n']* newline

let digit = '-'? ['0'-'9']
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

let identifier = letter (letter | digit)*
let int_constant = '-'? digit+

rule token = parse
| whitespace
  { token lexbuf }
| comment
  { token lexbuf }
| int_constant as i
  { INT (int_of_string i) }
| d i m
  { DIM }
| a s
  { AS }
| n e w
  { NEW }
| s u b
  { SUB }
| w h i l e
  { WHILE }
| i f
  { IF }
| t h e n
  { THEN }
| e l s e i f
  { ELSEIF }
| e l s e
  { ELSE }
| e n d
  { END }
| l e f t
  { LEFT }
| r i g h t
  { RIGHT }
| a h e a d
  { AHEAD }
| h e r e
  { HERE }
| n o r t h
  { NORTH }
| e a s t
  { EAST }
| s o u t h
  { SOUTH }
| w e s t
  { WEST }
| t r u e
  { TRUE }
| f a l s e
  { FALSE }
| a n d
  { AND }
| o r
  { OR }
| n o t
  { NOT }
| identifier as id
  { ID (String.lowercase_ascii id) }
| '='
  { EQ }
| '('
  { LPAREN }
| ')'
  { RPAREN }
| ','
  { COMMA }
| '.'
  { DOT }
| newline
  { NEWLINE }
| eof
  { EOF }
