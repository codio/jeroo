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
  loop lexbuf (JavaParser.Incremental.translation_unit lexbuf.lex_curr_p)

let compile code =
  let lexbuf = Lexing.from_string code in

  (* get the first line from the code and pair the header to the correct language *)
  let ast = match (String.split_on_char '\n' code) with
    | "@Java" :: _ -> parse_java lexbuf
    | "@VB" :: _ -> VBParser.translation_unit VBLexer.token lexbuf
    | _ -> raise (HeaderException "Malformed Header")
  in
  Codegen.codegen ast
