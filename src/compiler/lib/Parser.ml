open AST
open Position

let parse_java extensions_code main_code =
  let rec loop lexbuf checkpoint pane =
    try
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
        let error_state = JavaParser.MenhirInterpreter.current_state_number env in
        let lnum = LexingUtils.get_lnum lexbuf in
        let cnum = LexingUtils.get_cnum lexbuf in
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
        raise (Exceptions.CompileException {
            pos = {
              lnum;
              cnum;
            };
            pane;
            exception_type = "error";
            message = "Syntax Error"
          })
    with
    | Exceptions.LexingException e ->
      raise (Exceptions.CompileException {
          pane;
          pos = e.pos;
          exception_type = e.exception_type;
          message = e.message;
        })
  in
  let extensions_code_lexbuf = Lexing.from_string extensions_code in
  let extension_fxns = loop extensions_code_lexbuf (JavaParser.Incremental.translation_unit extensions_code_lexbuf.lex_curr_p) Pane.Extensions in
  let main_code_lexbuf = Lexing.from_string main_code in
  let main_method = loop main_code_lexbuf (JavaParser.Incremental.translation_unit main_code_lexbuf.lex_curr_p) Pane.Main in
  {
    extension_fxns;
    main_fxn = (List.hd main_method);
    language = AST.Java
  }

let parse_vb extensions_code main_code =
  let rec loop lexbuf state checkpoint pane =
    try
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
        let error_state = VBParser.MenhirInterpreter.current_state_number env in
        let lnum = LexingUtils.get_lnum lexbuf in
        let cnum = LexingUtils.get_cnum lexbuf in
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
        raise (Exceptions.CompileException {
            pos = {
              lnum;
              cnum;
            };
            pane;
            exception_type = "error";
            message = "Syntax Error"
          })
    with
    | Exceptions.LexingException e -> raise (Exceptions.CompileException {
        pane;
        pos = e.pos;
        exception_type = e.exception_type;
        message = e.message;
      })
  in
  let extensions_code_lexbuf = Lexing.from_string extensions_code in
  let extension_fxns = loop extensions_code_lexbuf (VBLexerState.create ()) (VBParser.Incremental.translation_unit extensions_code_lexbuf.lex_curr_p) Pane.Extensions in
  let main_code_lexbuf = Lexing.from_string main_code in
  let main_method = loop main_code_lexbuf (VBLexerState.create ()) (VBParser.Incremental.translation_unit main_code_lexbuf.lex_curr_p) Pane.Main in
  {
    extension_fxns;
    main_fxn = (List.hd main_method);
    language = AST.VB;
  }

let parse_python extensions_code main_code =
  let rec loop lexbuf state checkpoint pane =
    try
      match checkpoint with
      | PythonParser.MenhirInterpreter.InputNeeded _ ->
        let token = PythonLexer.token state lexbuf in
        let startp = lexbuf.lex_start_p in
        let endp = lexbuf.lex_curr_p in
        let checkpoint = PythonParser.MenhirInterpreter.offer checkpoint (token, startp, endp) in
        loop lexbuf state checkpoint pane
      | PythonParser.MenhirInterpreter.Shifting _ | PythonParser.MenhirInterpreter.AboutToReduce _ ->
        let checkpoint = PythonParser.MenhirInterpreter.resume checkpoint in
        loop lexbuf state checkpoint pane
      | PythonParser.MenhirInterpreter.HandlingError env ->
        let error_state = PythonParser.MenhirInterpreter.current_state_number env in
        let message = PythonMessages.message error_state in
        let lnum = LexingUtils.get_lnum lexbuf in
        let cnum = LexingUtils.get_cnum lexbuf in
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
        raise (Exceptions.CompileException {
            pos = {
              lnum;
              cnum;
            };
            pane;
            exception_type = "error";
            message = "Syntax Error"
          })
    with
    | Exceptions.LexingException e -> raise (Exceptions.CompileException {
        pane;
        pos = e.pos;
        exception_type = e.exception_type;
        message = e.message;
      })
  in
  let extensions_code_lexbuf = Lexing.from_string extensions_code in
  let extension_fxns = loop extensions_code_lexbuf (PythonLexerState.create ()) (PythonParser.Incremental.fxns extensions_code_lexbuf.lex_curr_p) Pane.Extensions in
  let main_code_lexbuf = Lexing.from_string main_code in
  let main_fxn = loop main_code_lexbuf (PythonLexerState.create ()) (PythonParser.Incremental.main_fxn main_code_lexbuf.lex_curr_p) Pane.Main in
  {
    extension_fxns;
    main_fxn;
    language = AST.Python;
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
    parse_vb extensions_code main_code
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
