exception HeaderException of string

exception ParserException of {
    message: string;
    lnum: int;
  }

let parse_java lexbuf =
  let rec loop lexbuf checkpoint =
    match checkpoint with
    | JavaParser.MenhirInterpreter.InputNeeded _ ->
      let token = JavaLexer.token lexbuf in
      let startp = lexbuf.lex_start_p in
      let endp = lexbuf.lex_curr_p in
      let checkpoint = JavaParser.MenhirInterpreter.offer checkpoint (token, startp, endp) in
      loop lexbuf checkpoint
    | JavaParser.MenhirInterpreter.Shifting _ | JavaParser.MenhirInterpreter.AboutToReduce _ ->
      let checkpoint = JavaParser.MenhirInterpreter.resume checkpoint in
      loop lexbuf checkpoint
    | JavaParser.MenhirInterpreter.HandlingError env ->
      let state = JavaParser.MenhirInterpreter.current_state_number env in
      let lnum = lexbuf.lex_curr_p.pos_lnum in
      let message = JavaMessages.message state in
      raise (ParserException {
          message = message;
          lnum = lnum
        })
    | JavaParser.MenhirInterpreter.Accepted tree -> tree
    | JavaParser.MenhirInterpreter.Rejected ->
      let lnum = lexbuf.lex_curr_p.pos_lnum in
      raise (ParserException {
          message = "Syntax Error";
          lnum = lnum
        })
  in
  try
    loop lexbuf (JavaParser.Incremental.translation_unit lexbuf.lex_curr_p)
  with
  | JavaLexer.Error e -> raise (ParserException {
      message = e.message;
      lnum = e.lnum
    })

let parse_vb lexbuf =
  let rec loop lexbuf checkpoint =
    match checkpoint with
    | VBParser.MenhirInterpreter.InputNeeded _ ->
      let token = VBLexer.token lexbuf in
      let startp = lexbuf.lex_start_p in
      let endp = lexbuf.lex_curr_p in
      let checkpoint = VBParser.MenhirInterpreter.offer checkpoint (token, startp, endp) in
      loop lexbuf checkpoint
    | VBParser.MenhirInterpreter.Shifting _ | VBParser.MenhirInterpreter.AboutToReduce _ ->
      let checkpoint = VBParser.MenhirInterpreter.resume checkpoint in
      loop lexbuf checkpoint
    | VBParser.MenhirInterpreter.HandlingError env ->
      let state = VBParser.MenhirInterpreter.current_state_number env in
      let lnum = lexbuf.lex_curr_p.pos_lnum in
      let message = VBMessages.message state in
      raise (ParserException {
          message = message;
          lnum = lnum
        })
    | VBParser.MenhirInterpreter.Accepted tree -> tree
    | VBParser.MenhirInterpreter.Rejected ->
      let lnum = lexbuf.lex_curr_p.pos_lnum in
      raise (ParserException {
          message = "Syntax Error";
          lnum = lnum
        })
  in
  try
    loop lexbuf (VBParser.Incremental.translation_unit lexbuf.lex_curr_p)
  with
  | VBLexer.Error e -> raise (ParserException {
      message = e.message;
      lnum = e.lnum;
    })

let compile code =
  let lexbuf = Lexing.from_string code in

  (* get the first line from the code and pair the header to the correct language *)
  let ast = match (String.split_on_char '\n' code) with
    | "@Java" :: _ -> parse_java lexbuf
    | "@VB" :: _ -> parse_vb lexbuf
    | _ -> raise (HeaderException "Malformed Header")
  in
  Codegen.codegen ast
