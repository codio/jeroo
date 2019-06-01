{
open PythonLexerState
open PythonParser
open Lexing

exception Error of {
    message : string;
    lnum : int;
  }

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
      let curr_offset = state.curr_offset in
      let last_offset = Stack.top state.offset_stack in
      if curr_offset < last_offset
      then (ignore (Stack.pop state.offset_stack); DEDENT lnum)
      else if curr_offset > last_offset
      then (Stack.push curr_offset state.offset_stack; INDENT lnum)
      else _token state lexbuf
    }
and _token state = parse
  | (whitespace* comment? newline)* whitespace* comment? eof {
      (* If there are stray indentation levels, send corresponding DEDENT tokens to pair them up *)
      if (not (state.emitted_eof_nl)) then begin
        state.emitted_eof_nl <- true;
        let indent = Stack.top state.offset_stack in
        state.curr_offset <- indent;
        (* backtrack the lexer one token *)
        lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with
                              pos_cnum = lexbuf.lex_curr_p.pos_cnum - 1 };
        NEWLINE (LexingUtils.get_lnum lexbuf)
      end else if ((not (Stack.is_empty state.offset_stack)) && (Stack.top state.offset_stack) > 0) then begin
        ignore (Stack.pop state.offset_stack);
        let indent = Stack.top state.offset_stack in
        state.curr_offset <- indent;
        (* backtrack the lexer one token *)
        lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with
                              pos_cnum = lexbuf.lex_curr_p.pos_cnum - 1 };

        DEDENT (LexingUtils.get_lnum lexbuf)
      end else
        EOF (LexingUtils.get_lnum lexbuf)
    }
  | (whitespace* comment? newline)* whitespace* comment? "@@\n" {
      if (state.emitted_eof_nl == false) then begin
        state.emitted_eof_nl <- true;
        let indent = Stack.top state.offset_stack in
        state.curr_offset <- indent;
        (* backtrack the lexer 3 characters *)
        lexbuf.lex_curr_pos <- lexbuf.lex_curr_pos - 3;
        NEWLINE (LexingUtils.get_lnum lexbuf)
      end else if ((not (Stack.is_empty state.offset_stack)) && (Stack.top state.offset_stack) > 0) then begin
        ignore (Stack.pop state.offset_stack);
        let indent = Stack.top state.offset_stack in
        state.curr_offset <- indent;
        (* backtrack the lexer 3 characters *)
        lexbuf.lex_curr_pos <- lexbuf.lex_curr_pos - 3;
          DEDENT (LexingUtils.get_lnum lexbuf)
      end else begin
        LexingUtils.reset_lnum lexbuf;
        state.emitted_eof_nl <- false;
        MAIN_METH_SEP
      end
    }
  | ((whitespace* comment? newline)* whitespace* comment?) newline
    {
      let lnum = (LexingUtils.get_lnum lexbuf) in
      let lines = LexingUtils.count_lines (lexeme lexbuf) in
      LexingUtils.next_n_lines lines lexbuf;
      if state.nl_ignore <= 0 then begin
        state.curr_offset <- 0;
        offset state lexbuf;
        NEWLINE lnum
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
  | "@PYTHON\n"
      { HEADER }
  | "def"
      { DEF (LexingUtils.get_lnum lexbuf) }
  | "and"
      { AND (LexingUtils.get_lnum lexbuf) }
  | "or"
      { OR (LexingUtils.get_lnum lexbuf) }
  | "not"
      { NOT (LexingUtils.get_lnum lexbuf) }
  | "if"
      { IF (LexingUtils.get_lnum lexbuf) }
  | "elif"
      { ELIF (LexingUtils.get_lnum lexbuf) }
  | "else"
      { ELSE (LexingUtils.get_lnum lexbuf) }
  | "while"
      { WHILE (LexingUtils.get_lnum lexbuf) }
  | "True"
    { TRUE (LexingUtils.get_lnum lexbuf) }
  | "False"
    { FALSE (LexingUtils.get_lnum lexbuf) }
  | "NORTH"
      { NORTH (LexingUtils.get_lnum lexbuf) }
  | "SOUTH"
      { SOUTH (LexingUtils.get_lnum lexbuf) }
  | "EAST"
      { EAST (LexingUtils.get_lnum lexbuf) }
  | "WEST"
      { WEST (LexingUtils.get_lnum lexbuf) }
  | "AHEAD"
      { AHEAD (LexingUtils.get_lnum lexbuf) }
  | "HERE"
      { HERE (LexingUtils.get_lnum lexbuf) }
  | "LEFT"
      { LEFT (LexingUtils.get_lnum lexbuf) }
  | "RIGHT"
      { RIGHT (LexingUtils.get_lnum lexbuf) }
  | "self"
    { SELF (LexingUtils.get_lnum lexbuf) }
  | '('
      { LPAREN (LexingUtils.get_lnum lexbuf) }
  | ')'
      { RPAREN (LexingUtils.get_lnum lexbuf) }
  | ':'
      { COLON (LexingUtils.get_lnum lexbuf) }
  | ','
      { COMMA (LexingUtils.get_lnum lexbuf) }
  | '='
      { EQ (LexingUtils.get_lnum lexbuf) }
  | '.'
    { DOT (LexingUtils.get_lnum lexbuf) }
  | identifier as id
    {  ID (id, (LexingUtils.get_lnum lexbuf)) }
  | decimalinteger as i
    { INT ((int_of_string i), (LexingUtils.get_lnum lexbuf)) }
  | _ { raise (Error {
        message = "Illegal character: " ^ Lexing.lexeme lexbuf;
        lnum = LexingUtils.get_lnum lexbuf
      })}
and offset state = parse
  | e { }
  | ' ' { state.curr_offset <- state.curr_offset + 1; offset state lexbuf }
  | '\t' { state.curr_offset <- state.curr_offset + 8; offset state lexbuf }
