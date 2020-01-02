(****************************************************************************)
(* Jeroo is a programming language learning tool for students and teachers. *)
(* Copyright (C) <2019>  <Benjamin Konz>                                    *)
(*                                                                          *)
(* This program is free software: you can redistribute it and/or modify     *)
(* it under the terms of the GNU Affero General Public License as           *)
(* published by the Free Software Foundation, either version 3 of the       *)
(* License, or (at your option) any later version.                          *)
(*                                                                          *)
(* This program is distributed in the hope that it will be useful,          *)
(* but WITHOUT ANY WARRANTY; without even the implied warranty of           *)
(* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            *)
(* GNU Affero General Public License for more details.                      *)
(*                                                                          *)
(* You should have received a copy of the GNU Affero General Public License *)
(* along with this program.  If not, see <http://www.gnu.org/licenses/>.    *)
(****************************************************************************)

open AST
open Position

let make_main_fxn = function
  | { a = { id = "main"; stmts}; pos } :: [] -> { a = { stmts }; pos }
  | { a = { id; _ };  pos } :: [] -> raise (Exceptions.CompileException {
      pos;
      pane = Pane.Main;
      exception_type = "error";
      message = Printf.sprintf "main method should be named `main`, found `%s`\n" id
    })
  | { pos; _ } :: _ -> raise (Exceptions.CompileException {
      pos;
      pane = Pane.Main;
      exception_type = "error";
      message = "main method should be the only method in the main panel"
    })
  | [] -> raise (Exceptions.CompileException {
      pos = { lnum = 0; cnum = 0 };
      pane = Pane.Main;
      exception_type = "error";
      message = "cannot find main method"
    })

let parse_java extensions_code main_code =
  let parse code pane =
    let rec loop lexbuf checkpoint pane =
      match checkpoint with
      | JavaParser.MenhirInterpreter.InputNeeded _ ->
        let token = JavaLexer.token lexbuf in
        let startp = lexbuf.lex_start_p in
        let endp = lexbuf.lex_curr_p in
        let checkpoint = JavaParser.MenhirInterpreter.offer checkpoint (token, startp, endp) in
        loop lexbuf checkpoint pane
      | JavaParser.MenhirInterpreter.Shifting _ | JavaParser.MenhirInterpreter.AboutToReduce _ ->
        let checkpoint = JavaParser.MenhirInterpreter.resume checkpoint in
        loop lexbuf checkpoint pane
      | JavaParser.MenhirInterpreter.HandlingError env ->
        (* make the error message prefix, ex: "expected `;`" *)
        let error_state = JavaParser.MenhirInterpreter.current_state_number env in
        let message = JavaMessages.message error_state in

        raise (Exceptions.CompileException {
            pos = {
              lnum = LexingUtils.get_lnum lexbuf;
              cnum = LexingUtils.get_cnum lexbuf;
            };
            pane;
            exception_type = "error";
            message
          })
      | JavaParser.MenhirInterpreter.Accepted tree -> tree
      | JavaParser.MenhirInterpreter.Rejected ->
        let lnum = LexingUtils.get_lnum lexbuf in
        let cnum = LexingUtils.get_cnum lexbuf in
        raise (Exceptions.CompileException {
            pos = {
              lnum;
              cnum;
            };
            pane;
            exception_type = "error";
            message = "Syntax Error"
          })
    in
    try
      let lexbuf = Lexing.from_string code in
      loop lexbuf (JavaParser.Incremental.translation_unit lexbuf.lex_curr_p) pane
    with
    | Exceptions.LexingException e ->
      raise (Exceptions.CompileException {
          pane;
          pos = e.pos;
          exception_type = e.exception_type;
          message = e.message;
        })
  in
  let extension_fxns = parse extensions_code Pane.Extensions in
  let main_fxns = parse main_code Pane.Main in
  let main_fxn = make_main_fxn main_fxns in
  {
    extension_fxns;
    main_fxn;
  }

let parse_vb extensions_code main_code =
  let parse code pane =
    let rec loop lexbuf state checkpoint pane =
      match checkpoint with
      | VBParser.MenhirInterpreter.InputNeeded _ ->
        let token = VBLexer.token state lexbuf in
        let startp = lexbuf.lex_start_p in
        let endp = lexbuf.lex_curr_p in
        let checkpoint = VBParser.MenhirInterpreter.offer checkpoint (token, startp, endp) in
        loop lexbuf state checkpoint pane
      | VBParser.MenhirInterpreter.Shifting _ | VBParser.MenhirInterpreter.AboutToReduce _ ->
        let checkpoint = VBParser.MenhirInterpreter.resume checkpoint in
        loop lexbuf state checkpoint pane
      | VBParser.MenhirInterpreter.HandlingError env ->
        (* make the error message prefix, ex: "expected new line" *)
        let error_state = VBParser.MenhirInterpreter.current_state_number env in
        let message = VBMessages.message error_state in

        raise (Exceptions.CompileException {
            pos = {
              lnum = LexingUtils.get_lnum lexbuf;
              cnum = LexingUtils.get_cnum lexbuf;
            };
            pane;
            exception_type = "error";
            message
          })
      | VBParser.MenhirInterpreter.Accepted tree -> tree
      | VBParser.MenhirInterpreter.Rejected ->
        (* this should never happen *)
        raise (Exceptions.CompileException {
            pos = {
              lnum = LexingUtils.get_lnum lexbuf;
              cnum = LexingUtils.get_cnum lexbuf;
            };
            pane;
            exception_type = "error";
            message = "Syntax Error"
          })
    in
    try
      let lexbuf = Lexing.from_string code in
      loop lexbuf (VBLexerState.create ()) (VBParser.Incremental.translation_unit lexbuf.lex_curr_p) pane
    with
    | Exceptions.LexingException e -> raise (Exceptions.CompileException {
        pane;
        pos = e.pos;
        exception_type = e.exception_type;
        message = e.message;
      })
  in
  let extension_fxns = parse extensions_code Pane.Extensions in
  let main_fxns = parse main_code Pane.Main in
  let main_fxn = make_main_fxn main_fxns in
  {
    extension_fxns;
    main_fxn;
  }

let parse_python extensions_code main_code =
  let rec loop code lexbuf state checkpoint pane =
    match checkpoint with
    | PythonParser.MenhirInterpreter.InputNeeded _ ->
      let token = PythonLexer.token state lexbuf in
      let startp = lexbuf.lex_start_p in
      let endp = lexbuf.lex_curr_p in
      let checkpoint = PythonParser.MenhirInterpreter.offer checkpoint (token, startp, endp) in
      loop code lexbuf state checkpoint pane
    | PythonParser.MenhirInterpreter.Shifting _ | PythonParser.MenhirInterpreter.AboutToReduce _ ->
      let checkpoint = PythonParser.MenhirInterpreter.resume checkpoint in
      loop code lexbuf state checkpoint pane
    | PythonParser.MenhirInterpreter.HandlingError env ->
      (* make the error message prefix, ex: "expected `:`" *)
      let error_state = PythonParser.MenhirInterpreter.current_state_number env in
      let message = PythonMessages.message error_state in

      raise (Exceptions.CompileException {
          pos = {
            lnum = LexingUtils.get_lnum lexbuf;
            cnum = LexingUtils.get_cnum lexbuf;
          };
          pane;
          exception_type = "error";
          message
        })
    | PythonParser.MenhirInterpreter.Accepted tree -> tree
    | PythonParser.MenhirInterpreter.Rejected ->
      let lnum = LexingUtils.get_lnum lexbuf in
      let cnum = LexingUtils.get_cnum lexbuf in
      raise (Exceptions.CompileException {
          pos = {
            lnum;
            cnum;
          };
          pane;
          exception_type = "error";
          message = "Syntax Error"
        })
  in
  let extension_fxns =
    try
      let extensions_code_lexbuf = Lexing.from_string extensions_code in
      loop
        extensions_code
        extensions_code_lexbuf
        (PythonLexerState.create ())
        (PythonParser.Incremental.fxns extensions_code_lexbuf.lex_curr_p)
        Pane.Extensions
    with
    | Exceptions.LexingException e -> raise (Exceptions.CompileException {
        pane = Pane.Extensions;
        pos = e.pos;
        exception_type = e.exception_type;
        message = e.message;
      })
  in
  let main_fxn = try
      let main_code_lexbuf = Lexing.from_string main_code in
      loop
        main_code
        main_code_lexbuf
        (PythonLexerState.create ())
        (PythonParser.Incremental.main_fxn main_code_lexbuf.lex_curr_p)
        Pane.Main
    with
    | Exceptions.LexingException e -> raise (Exceptions.CompileException {
        pane = Pane.Main;
        pos = e.pos;
        exception_type = e.exception_type;
        message = e.message;
      })
  in
  {
    extension_fxns;
    main_fxn;
  }

let split_code lines =
  let rec split lines in_extensions main_code_lines extension_code_lines =
    match lines with
    | "@@" :: xs when in_extensions -> split xs false main_code_lines extension_code_lines
    | x :: xs when in_extensions -> split xs in_extensions main_code_lines (x :: extension_code_lines)
    | x :: xs -> split xs in_extensions (x :: main_code_lines) extension_code_lines
    | [] -> (extension_code_lines, main_code_lines)
  in
  let (extension_code_lines, main_code_lines) = split lines true [] [] in
  (
    extension_code_lines |> List.rev |> (String.concat "\n"),
    main_code_lines |> List.rev |> (String.concat "\n")
  )

let parse code =
  match (String.split_on_char '\n' code) with
  | "@Java" :: lines ->
    let (extensions_code, main_code) = split_code lines in
    parse_java extensions_code main_code
  | "@VB" :: lines ->
    let (extensions_code, main_code) = split_code lines in
    let ast = parse_vb extensions_code main_code in
    ast
  | "@PYTHON" :: lines ->
    let (extensions_code, main_code) = split_code lines in
    parse_python extensions_code main_code
  | _ ->
    raise (Exceptions.CompileException {
        pos = {
          lnum = 0;
          cnum = 0;
        };
        pane = Pane.Main;
        exception_type = "error";
        message = "Malformed Header"
      })
