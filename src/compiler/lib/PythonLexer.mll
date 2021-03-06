{
open PythonLexerState
open PythonParser
open Lexing
}

(* epsilon *)
let e = ""

let newline = ('\n' | "\r\n")
let whitespace = [' ' '\t']
let comment = '#' [^ '\n' '\r']*

let digit = ['0'-'9']
let nonzerodigit = ['1'-'9']
let decimalinteger = ['+' '-']? (digit | (nonzerodigit digit+))
let identifier = ['a'-'z' 'A'-'Z' '_']['a'-'z' 'A'-'Z' '0'-'9' '_']*

rule token state = parse
  | e {
      let lnum = LexingUtils.get_lnum lexbuf in
      let cnum = LexingUtils.get_cnum lexbuf in
      let curr_offset = state.curr_offset in
      let last_offset = Stack.top state.offset_stack in
      if curr_offset < last_offset
      then (ignore (Stack.pop state.offset_stack); DEDENT { lnum; cnum })
      else if curr_offset > last_offset
      then (Stack.push curr_offset state.offset_stack; INDENT { lnum; cnum })
      else _token state lexbuf
    }
and _token state = parse
  | (whitespace* comment? newline)* whitespace* comment? eof {
      let lnum = LexingUtils.get_lnum lexbuf in
      let cnum = LexingUtils.get_cnum lexbuf in
      (* If there are stray indentation levels, send corresponding DEDENT tokens to pair them up *)
      if (not (state.emitted_eof_nl)) then begin
        state.emitted_eof_nl <- true;
        let indent = Stack.top state.offset_stack in
        state.curr_offset <- indent;
        (* backtrack the lexer one token *)
        lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with
                              pos_cnum = lexbuf.lex_curr_p.pos_cnum - 1 };
        NEWLINE { lnum; cnum }
      end else if ((not (Stack.is_empty state.offset_stack)) && (Stack.top state.offset_stack) > 0) then begin
        ignore (Stack.pop state.offset_stack);
        let indent = Stack.top state.offset_stack in
        state.curr_offset <- indent;
        (* backtrack the lexer one token *)
        lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with
                              pos_cnum = lexbuf.lex_curr_p.pos_cnum - 1 };

        DEDENT { lnum; cnum }
      end else
        EOF
    }
  | ((whitespace* comment? newline)* whitespace* comment?) newline
    {
      let lnum = LexingUtils.get_lnum lexbuf in
      let cnum = LexingUtils.get_cnum lexbuf in
      let lines = LexingUtils.count_lines (lexeme lexbuf) in
      LexingUtils.next_n_lines lines lexbuf;
      if state.nl_ignore <= 0 then begin
        state.curr_offset <- 0;
        offset state lexbuf;
        NEWLINE { lnum; cnum }
      end else
        _token state lexbuf
    }
  | '\\' newline whitespace*
    {
      let pos = lexbuf.lex_curr_p in
      lexbuf.lex_curr_p <-
        { pos with
          pos_bol = pos.pos_cnum;
          pos_lnum = pos.pos_lnum + 1 };
      _token state lexbuf
    }
  | whitespace+
    { _token state lexbuf }
  | "def"
      { DEF ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "and"
      { AND ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "or"
      { OR ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "not"
      { NOT ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "if"
      { IF ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "elif"
      { ELIF ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "else"
      { ELSE ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "while"
      { WHILE ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "True"
    { TRUE ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "False"
    { FALSE ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "NORTH"
      { NORTH ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "SOUTH"
      { SOUTH ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "EAST"
      { EAST ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "WEST"
      { WEST ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "AHEAD"
      { AHEAD ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "HERE"
      { HERE ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "LEFT"
      { LEFT ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "RIGHT"
      { RIGHT ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | "self"
    { SELF ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | '('
      { LPAREN ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | ')'
      { RPAREN ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | ':'
      { COLON ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | ','
      { COMMA ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | '='
      { EQ ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | '.'
    { DOT ({ lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }, (Lexing.lexeme lexbuf)) }
  | identifier as id
    {  ID (id, { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }) }
  | decimalinteger as i
    { INT ((int_of_string i), { lnum = LexingUtils.get_lnum lexbuf; cnum = LexingUtils.get_cnum lexbuf }) }
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
and offset state = parse
  | e { }
  | ' ' { state.curr_offset <- state.curr_offset + 1; offset state lexbuf }
  | '\t' { state.curr_offset <- state.curr_offset + 8; offset state lexbuf }
