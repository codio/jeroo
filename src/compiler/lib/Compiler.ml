let parse_java lexbuf =
  let rec loop (lexbuf : Lexing.lexbuf) (state : JavaLexerState.t) checkpoint =
    match checkpoint with
    | JavaParser.MenhirInterpreter.InputNeeded _ ->
      let token = JavaLexer.token state lexbuf in
      let startp = lexbuf.lex_start_p in
      let endp = lexbuf.lex_curr_p in
      let checkpoint = JavaParser.MenhirInterpreter.offer checkpoint (token, startp, endp) in
      loop lexbuf state checkpoint
    | JavaParser.MenhirInterpreter.Shifting _ | JavaParser.MenhirInterpreter.AboutToReduce _ ->
      let checkpoint = JavaParser.MenhirInterpreter.resume checkpoint in
      loop lexbuf state checkpoint
    | JavaParser.MenhirInterpreter.HandlingError env ->
      let error_state = JavaParser.MenhirInterpreter.current_state_number env in
      let lnum = LexingUtils.get_lnum lexbuf in
      let cnum = LexingUtils.get_cnum lexbuf in
      let pane = if state.in_main then Pane.Main else Pane.Extensions in
      let message = JavaMessages.message error_state in
      raise (Exceptions.CompileException {
          pos = {
            lnum;
            cnum
          };
          pane;
          exception_type = "error";
          message
        })
    | JavaParser.MenhirInterpreter.Accepted tree -> tree
    | JavaParser.MenhirInterpreter.Rejected ->
      let lnum = LexingUtils.get_lnum lexbuf in
      let cnum = LexingUtils.get_cnum lexbuf in
      let pane = if state.in_main then Pane.Main else Pane.Extensions in
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
  loop lexbuf (JavaLexerState.create ()) (JavaParser.Incremental.translation_unit lexbuf.lex_curr_p)

let parse_vb lexbuf =
  let rec loop lexbuf state checkpoint =
    match checkpoint with
    | VBParser.MenhirInterpreter.InputNeeded _ ->
      let token = VBLexer.token state lexbuf in
      let startp = lexbuf.lex_start_p in
      let endp = lexbuf.lex_curr_p in
      let checkpoint = VBParser.MenhirInterpreter.offer checkpoint (token, startp, endp) in
      loop lexbuf state checkpoint
    | VBParser.MenhirInterpreter.Shifting _ | VBParser.MenhirInterpreter.AboutToReduce _ ->
      let checkpoint = VBParser.MenhirInterpreter.resume checkpoint in
      loop lexbuf state checkpoint
    | VBParser.MenhirInterpreter.HandlingError env ->
      let error_state = VBParser.MenhirInterpreter.current_state_number env in
      let lnum = LexingUtils.get_lnum lexbuf in
      let cnum = LexingUtils.get_cnum lexbuf in
      let pane = if state.in_main then Pane.Main else Pane.Extensions in
      let message = VBMessages.message error_state in
      raise (Exceptions.CompileException {
          pos = {
            lnum;
            cnum;
          };
          pane;
          exception_type = "error";
          message
        })
    | VBParser.MenhirInterpreter.Accepted tree -> tree
    | VBParser.MenhirInterpreter.Rejected ->
      let lnum = LexingUtils.get_lnum lexbuf in
      let cnum = LexingUtils.get_cnum lexbuf in
      let pane = if state.in_main then Pane.Main else Pane.Extensions in
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
  loop lexbuf (VBLexerState.create ()) (VBParser.Incremental.translation_unit lexbuf.lex_curr_p)

let parse_python lexbuf =
  let rec loop lexbuf state checkpoint =
    match checkpoint with
    | PythonParser.MenhirInterpreter.InputNeeded _ ->
      let token = PythonLexer.token state lexbuf in
      let startp = lexbuf.lex_start_p in
      let endp = lexbuf.lex_curr_p in
      let checkpoint = PythonParser.MenhirInterpreter.offer checkpoint (token, startp, endp) in
      loop lexbuf state checkpoint
    | PythonParser.MenhirInterpreter.Shifting _ | PythonParser.MenhirInterpreter.AboutToReduce _ ->
      let checkpoint = PythonParser.MenhirInterpreter.resume checkpoint in
      loop lexbuf state checkpoint
    | PythonParser.MenhirInterpreter.HandlingError env ->
      let error_state = PythonParser.MenhirInterpreter.current_state_number env in
      let message = PythonMessages.message error_state in
      let lnum = LexingUtils.get_lnum lexbuf in
      let cnum = LexingUtils.get_cnum lexbuf in
      let pane = if state.in_main then Pane.Main else Pane.Extensions in
      raise (Exceptions.CompileException {
          pos = {
            lnum;
            cnum;
          };
          pane;
          exception_type = "error";
          message
        })
    | PythonParser.MenhirInterpreter.Accepted tree -> tree
    | PythonParser.MenhirInterpreter.Rejected ->
      let lnum = LexingUtils.get_lnum lexbuf in
      let cnum = LexingUtils.get_cnum lexbuf in
      let pane = if state.in_main then Pane.Main else Pane.Extensions in
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
  loop lexbuf (PythonLexerState.create ()) (PythonParser.Incremental.translation_unit lexbuf.lex_curr_p)

let compile code =
  let lexbuf = Lexing.from_string code in
  (* get the first line from the code and pair the header to the correct language *)
  let ast = match (String.split_on_char '\n' code) with
    | "@Java" :: _ -> parse_java lexbuf
    | "@VB" :: _ -> parse_vb lexbuf
    | "@PYTHON" :: _ -> parse_python lexbuf
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
  in
  TypeChecker.type_check ast;
  Codegen.codegen ast
