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

(* returns a pair of stacks of string position pairs, representing the token string and the position of the token *)
(* the first stack is the unbalanced `(` token's and the second stack is the unablanced `{` token's *)
(* re-lexes the entire code and throws a lexing exception if there are any lexing errors in the code *)
let find_unbalanced_java_tokens code =
  let rec loop lexbuf paren_stack bracket_stack =
    let token = JavaLexer.token lexbuf in
    match token with
    | JavaParser.LPAREN data ->
      Stack.push data paren_stack;
      loop lexbuf paren_stack bracket_stack
    | JavaParser.LBRACKET data ->
      Stack.push data bracket_stack;
      loop lexbuf paren_stack bracket_stack
    | JavaParser.RPAREN _ when not (Stack.is_empty paren_stack) ->
      ignore (Stack.pop paren_stack);
      loop lexbuf paren_stack bracket_stack
    | JavaParser.RBRACKET _ when not (Stack.is_empty bracket_stack) ->
      ignore (Stack.pop bracket_stack);
      loop lexbuf paren_stack bracket_stack
    | JavaParser.EOF ->
      ()
    | _ ->
      loop lexbuf paren_stack bracket_stack
  in
  (* reset the lexbuf *)
  let lexbuf = Lexing.from_string code in
  let paren_stack = Stack.create () in
  let bracket_stack = Stack.create () in
  loop lexbuf paren_stack bracket_stack;
  paren_stack, bracket_stack

(* finds the unmatched python tokens and returns a stack of unbalanced tokens *)
(* only unbalanced parenthesis are returned, since unbalanced indentation levels are accounted for in the lexer *)
let find_unbalanced_python_tokens code =
  let rec loop lexbuf lexing_state paren_stack =
    let token = PythonLexer.token lexing_state lexbuf in
    match token with
    | PythonParser.LPAREN data ->
      Stack.push data paren_stack;
      loop lexbuf lexing_state paren_stack
    | PythonParser.RPAREN _ ->
      ignore (Stack.pop paren_stack);
      loop lexbuf lexing_state paren_stack
    | PythonParser.EOF ->
      ()
    | _ ->
      loop lexbuf lexing_state paren_stack
  in
  (* reset the lexbuf *)
  let lexbuf = Lexing.from_string code in
  let paren_stack = Stack.create () in
  loop lexbuf (PythonLexerState.create ()) paren_stack;
  paren_stack

(* finds the unmatched vb tokens and returns stacks containing the unmatched parens, sub/end sub, if/end if, and while/end while *)
let find_unbalanced_vb_tokens code =
  let rec loop lexbuf lexing_state paren_stack sub_stack if_stack while_stack =
    let token = VBLexer.token lexing_state lexbuf in
    match token with
    | VBParser.LPAREN data ->
      Stack.push data paren_stack;
      loop lexbuf lexing_state paren_stack sub_stack if_stack while_stack
    | VBParser.SUB data ->
      Stack.push data sub_stack;
      loop lexbuf lexing_state paren_stack sub_stack if_stack while_stack
    | VBParser.IF data ->
      Stack.push data if_stack;
      loop lexbuf lexing_state paren_stack sub_stack if_stack while_stack
    | VBParser.WHILE data ->
      Stack.push data while_stack;
      loop lexbuf lexing_state paren_stack sub_stack if_stack while_stack
    | VBParser.RPAREN _ ->
      ignore (Stack.pop paren_stack);
      loop lexbuf lexing_state paren_stack sub_stack if_stack while_stack
    | VBParser.ENDSUB _ ->
      ignore (Stack.pop sub_stack);
      loop lexbuf lexing_state paren_stack sub_stack if_stack while_stack
    | VBParser.ENDIF _ ->
      ignore (Stack.pop if_stack);
      loop lexbuf lexing_state paren_stack sub_stack if_stack while_stack
    | VBParser.ENDWHILE _ ->
      ignore (Stack.pop while_stack);
      loop lexbuf lexing_state paren_stack sub_stack if_stack while_stack
    | VBParser.EOF ->
      ()
    | _ ->
      loop lexbuf lexing_state paren_stack sub_stack if_stack while_stack
  in
  let lexbuf = Lexing.from_string code in
  let lexing_state = VBLexerState.create () in
  let paren_stack = Stack.create () in
  let sub_stack = Stack.create () in
  let if_stack = Stack.create () in
  let while_stack = Stack.create () in
  loop lexbuf lexing_state paren_stack sub_stack if_stack while_stack;
  paren_stack, sub_stack, if_stack, while_stack

let make_unablanced_help_msg unbalanced_stack =
  unbalanced_stack
  |> Stack.fold (fun msgs (pos, s) ->
      (Printf.sprintf "hint: unclosed `%s` on line %d: column %d" s pos.lnum pos.cnum) :: msgs) []

let parse_java extensions_code main_code =
  let parse code pane =
    let rec loop lexbuf checkpoint pane last_token_opt =
      try
        match checkpoint with
        | JavaParser.MenhirInterpreter.InputNeeded _ ->
          let token = JavaLexer.token lexbuf in
          let startp = lexbuf.lex_start_p in
          let endp = lexbuf.lex_curr_p in
          let checkpoint = JavaParser.MenhirInterpreter.offer checkpoint (token, startp, endp) in
          loop lexbuf checkpoint pane (Some token)
        | JavaParser.MenhirInterpreter.Shifting _ | JavaParser.MenhirInterpreter.AboutToReduce _ ->
          let checkpoint = JavaParser.MenhirInterpreter.resume checkpoint in
          loop lexbuf checkpoint pane last_token_opt
        | JavaParser.MenhirInterpreter.HandlingError env ->
          (* make the unbalanced help messages *)
          let unclosed_paren_stack, unclosed_bracket_stack = find_unbalanced_java_tokens code in
          let unclosed_paren_help_msgs = make_unablanced_help_msg unclosed_paren_stack in
          let unclosed_bracket_help_msgs = make_unablanced_help_msg unclosed_bracket_stack in
          let unclosed_help_msg =
            unclosed_paren_help_msgs @ unclosed_bracket_help_msgs
            |> String.concat "\n"
          in

          (* make the error message prefix, ex: "expected `;`" *)
          let error_state = JavaParser.MenhirInterpreter.current_state_number env in
          let message_prefix = JavaMessages.message error_state |> String.trim in

          (* make the error message suffix, ex: ", found `)`" *)
          let message_suffix = match last_token_opt with
            | Some token when token <> JavaParser.EOF ->
              Printf.sprintf ", found `%s`"
                (JavaTokenMapper.map_token token)
            | _ -> ""
          in

          let message = message_prefix ^ message_suffix ^ "\n" ^ unclosed_help_msg in
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
      with
      | Exceptions.LexingException e ->
        raise (Exceptions.CompileException {
            pane;
            pos = e.pos;
            exception_type = e.exception_type;
            message = e.message;
          })
    in
    let lexbuf = Lexing.from_string code in
    loop lexbuf (JavaParser.Incremental.translation_unit lexbuf.lex_curr_p) pane None
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
    let rec loop lexbuf state checkpoint pane last_token_opt =
      try
        match checkpoint with
        | VBParser.MenhirInterpreter.InputNeeded _ ->
          let token = VBLexer.token state lexbuf in
          let startp = lexbuf.lex_start_p in
          let endp = lexbuf.lex_curr_p in
          let checkpoint = VBParser.MenhirInterpreter.offer checkpoint (token, startp, endp) in
          loop lexbuf state checkpoint pane (Some token)
        | VBParser.MenhirInterpreter.Shifting _ | VBParser.MenhirInterpreter.AboutToReduce _ ->
          let checkpoint = VBParser.MenhirInterpreter.resume checkpoint in
          loop lexbuf state checkpoint pane last_token_opt
        | VBParser.MenhirInterpreter.HandlingError env ->
          (* make the unbalanced help messages *)
          let
            unclosed_paren_stack,
            unclosed_sub_stack,
            unclosed_if_stack,
            unclosed_while_stack
            = find_unbalanced_vb_tokens code
          in
          let unclosed_paren_help_msgs = make_unablanced_help_msg unclosed_paren_stack in
          let unclosed_sub_help_msgs = make_unablanced_help_msg unclosed_sub_stack in
          let unclosed_if_help_msgs = make_unablanced_help_msg unclosed_if_stack in
          let unclosed_while_stack = make_unablanced_help_msg unclosed_while_stack in
          let unclosed_help_msg =
            unclosed_paren_help_msgs @
            unclosed_if_help_msgs @
            unclosed_while_stack @
            unclosed_sub_help_msgs
            |> String.concat "\n"
          in

          (* make the error message prefix, ex: "expected new line" *)
          let error_state = VBParser.MenhirInterpreter.current_state_number env in
          let message_prefix = VBMessages.message error_state |> String.trim in

          (* make the error message suffix, ex: ", found `)`" *)
          let message_suffix = match last_token_opt with
            | Some token when token <> VBParser.EOF ->
              Printf.sprintf ", found `%s`"
                (VBTokenMapper.map_token token)
            | _ -> ""
          in

          let message = message_prefix ^ message_suffix ^ "\n" ^ unclosed_help_msg in
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
      with
      | Exceptions.LexingException e -> raise (Exceptions.CompileException {
          pane;
          pos = e.pos;
          exception_type = e.exception_type;
          message = e.message;
        })
    in
    let lexbuf = Lexing.from_string code in
    loop lexbuf (VBLexerState.create ()) (VBParser.Incremental.translation_unit lexbuf.lex_curr_p) pane None
  in
  let extension_fxns = parse extensions_code Pane.Extensions in
  let main_fxns = parse main_code Pane.Main in
  let main_fxn = make_main_fxn main_fxns in
  {
    extension_fxns;
    main_fxn;
  }

let parse_python extensions_code main_code =
  let rec loop code lexbuf state checkpoint pane last_token_opt =
    try
      match checkpoint with
      | PythonParser.MenhirInterpreter.InputNeeded _ ->
        let token = PythonLexer.token state lexbuf in
        let startp = lexbuf.lex_start_p in
        let endp = lexbuf.lex_curr_p in
        let checkpoint = PythonParser.MenhirInterpreter.offer checkpoint (token, startp, endp) in
        loop code lexbuf state checkpoint pane (Some token)
      | PythonParser.MenhirInterpreter.Shifting _ | PythonParser.MenhirInterpreter.AboutToReduce _ ->
        let checkpoint = PythonParser.MenhirInterpreter.resume checkpoint in
        loop code lexbuf state checkpoint pane last_token_opt
      | PythonParser.MenhirInterpreter.HandlingError env ->
        (* make the unbalanced help message *)
        let unclosed_paren_stack = find_unbalanced_python_tokens code in
        let unclosed_paren_help_msgs = make_unablanced_help_msg unclosed_paren_stack in
        let unclosed_help_msg = unclosed_paren_help_msgs |> String.concat "\n" in

        (* make the error message prefix, ex: "expected `:`" *)
        let error_state = PythonParser.MenhirInterpreter.current_state_number env in
        let message_prefix = PythonMessages.message error_state |> String.trim in

        (* make the error message suffix, ex: ", found `)`" *)
        let message_suffix = match last_token_opt with
          | Some token when token <> PythonParser.EOF  ->
            Printf.sprintf ", found `%s`"
              (PythonTokenMapper.map_token token)
          | _ -> ""
        in

        let message = message_prefix ^ message_suffix ^ "\n" ^ unclosed_help_msg in
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
    with
    | Exceptions.LexingException e -> raise (Exceptions.CompileException {
        pane;
        pos = e.pos;
        exception_type = e.exception_type;
        message = e.message;
      })
  in
  let extensions_code_lexbuf = Lexing.from_string extensions_code in
  let extension_fxns = loop
      extensions_code
      extensions_code_lexbuf
      (PythonLexerState.create ())
      (PythonParser.Incremental.fxns extensions_code_lexbuf.lex_curr_p)
      Pane.Extensions
      None
  in
  let main_code_lexbuf = Lexing.from_string main_code in
  let main_fxn = loop
      main_code
      main_code_lexbuf
      (PythonLexerState.create ())
      (PythonParser.Incremental.main_fxn main_code_lexbuf.lex_curr_p)
      Pane.Main
      None
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
