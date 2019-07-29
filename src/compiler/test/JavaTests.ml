open OUnit2
open Lib
open AST

let parse_method _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { }"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [];
                     start_lnum = 1;
                     end_lnum = 1;
                   };
                 }
  in
  assert_equal ~printer:[%show: AST.translation_unit] ast expected

let parse_decl _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { Jeroo j = new Jeroo(1, 2); }"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.DeclStmt("Jeroo", "j", {
                           a = AST.UnOpExpr(AST.New, {
                               a = AST.FxnAppExpr({
                                   a = AST.IdExpr("Jeroo");
                                   pos = { lnum = 1; cnum = 35 };
                                 },
                                   [
                                     {
                                       a = AST.IntExpr(1);
                                       pos = { lnum = 1; cnum = 37 };
                                     };
                                     {
                                       a = AST.IntExpr(2);
                                       pos = { lnum = 1; cnum = 40 };
                                     }
                                   ]);
                               pos = { lnum = 1; cnum = 35 };
                             });
                           pos = { lnum = 1; cnum = 29 };
                         })
                     ];
                     start_lnum = 1;
                     end_lnum = 1;
                   };
                 }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_if_stmt _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { if (true) { } }"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt {
                         a = ({
                             a = AST.TrueExpr;
                             pos = { lnum = 1; cnum = 24 };
                           }, AST.BlockStmt []);
                         pos = { lnum = 1; cnum = 18 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 1;
                   };
                 }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_if_else_stmt _test_ctxt =
  let code =
    "@Java\n" ^
    "@@\n" ^
    "method main() { if (true) { } else { }}"
  in
  let ast = Parser.parse code in
  let expected = { AST.extension_fxns = [];
                   main_fxn =
                     { AST.id = "main";
                       stmts =
                         [(AST.IfElseStmt
                             { AST.a =
                                 ({ AST.a = AST.TrueExpr; pos = { Position.lnum = 1; cnum = 24 } },
                                  (AST.BlockStmt []), (AST.BlockStmt []));
                               pos = { Position.lnum = 1; cnum = 18 } })
                         ];
                       start_lnum = 1; end_lnum = 1 };
                   language = AST.Java }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_dangling_if _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { if (true) if (false) {} else { }}"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt{
                         a = {
                           a = AST.TrueExpr;
                           pos = { lnum = 1; cnum = 24 };
                         }, AST.IfElseStmt
                             { a = ({
                                   a = AST.FalseExpr;
                                   pos = { lnum = 1; cnum = 35 };
                                 }, AST.BlockStmt [], AST.BlockStmt []);
                               pos = { lnum = 1; cnum = 28 };
                             };
                         pos = { lnum = 1; cnum = 18 };
                       };
                     ];
                     start_lnum = 1;
                     end_lnum = 1;
                   };
                 }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_while_stmt _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { while(true) { }}"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.WhileStmt {
                         a = ({
                             a = AST.TrueExpr;
                             pos = { lnum = 1; cnum = 26 };
                           }, AST.BlockStmt []);
                         pos = { lnum = 1; cnum = 21 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 1;
                   };
                 }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_and _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { if (true && true) { }}"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt
                         {
                           a = ({
                               a = AST.BinOpExpr({
                                   a = AST.TrueExpr;
                                   pos = { lnum = 1; cnum = 24 };
                                 }, AST.And, {
                                     a = AST.TrueExpr;
                                     pos = { lnum = 1; cnum = 32 };
                                   });
                               pos = { lnum = 1; cnum = 27 };
                             }, AST.BlockStmt []);
                           pos = { lnum = 1; cnum = 18 };
                         }
                     ];
                     start_lnum = 1;
                     end_lnum = 1;
                   };
                 }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_or _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { if (true || true) { }}"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt
                         { a = ({
                               a = AST.BinOpExpr({
                                   a = AST.TrueExpr;
                                   pos = { lnum = 1; cnum = 24 };
                                 }, AST.Or, {
                                     a = AST.TrueExpr;
                                     pos = { lnum = 1; cnum = 32 };
                                   });
                               pos = { lnum = 1; cnum = 27 };
                             }, AST.BlockStmt []);
                           pos = { lnum = 1; cnum = 18 };
                         };
                     ];
                     start_lnum = 1;
                     end_lnum = 1;
                   }
                 }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_not _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { if (!true) {} }"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt
                         { a = ({
                               a = AST.UnOpExpr(AST.Not, {
                                   a = AST.TrueExpr;
                                   pos = { lnum = 1; cnum = 25 };
                                 });
                               pos = { lnum = 1; cnum = 21 };
                             }, AST.BlockStmt []);
                           pos = { lnum = 1; cnum = 18 };
                         };
                     ];
                     start_lnum = 1;
                     end_lnum = 1;
                   }
                 }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_not_precedence _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { if (!true && false) {}}"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt
                         { a = ({
                               a = AST.BinOpExpr({
                                   a = AST.UnOpExpr(AST.Not, {
                                       a = AST.TrueExpr;
                                       pos = { lnum = 1; cnum = 25 };
                                     });
                                   pos = { lnum = 1; cnum = 21 };
                                 }, AST.And, {
                                     a = AST.FalseExpr;
                                     pos = { lnum = 1; cnum = 34 };
                                   });
                               pos = { lnum = 1; cnum = 28 };
                             }, AST.BlockStmt []);
                           pos = { lnum = 1; cnum = 18 };
                         };
                     ];
                     start_lnum = 1;
                     end_lnum = 1;
                   }
                 }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_paren_precedence _test_ctxt =
  let code =
    "@Java\n" ^
    "@@\n" ^
    "method main() { if (true && (false && false)) {} }"
  in
  let ast = Parser.parse code in
  let expected = { AST.extension_fxns = [];
                   main_fxn =
                     { AST.id = "main";
                       stmts =
                         [(AST.IfStmt
                             { AST.a =
                                 ({ AST.a =
                                      (AST.BinOpExpr (
                                          { AST.a = AST.TrueExpr;
                                            pos = { Position.lnum = 1; cnum = 24 } },
                                          AST.And,
                                          { AST.a =
                                              (AST.BinOpExpr (
                                                  { AST.a = AST.FalseExpr;
                                                    pos = { Position.lnum = 1; cnum = 34 } },
                                                  AST.And,
                                                  { AST.a = AST.FalseExpr;
                                                    pos = { Position.lnum = 1; cnum = 43 } }
                                                ));
                                            pos = { Position.lnum = 1; cnum = 37 } }
                                        ));
                                    pos = { Position.lnum = 1; cnum = 27 } },
                                  (AST.BlockStmt []));
                               pos = { Position.lnum = 1; cnum = 18 } })
                         ];
                       start_lnum = 1; end_lnum = 1 };
                   language = AST.Java }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_comment _test_ctxt =
  let code =
    "@Java\n" ^
    "// this is a comment\n" ^
    "@@\n" ^
    "method main() { }"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [];
                     start_lnum = 1;
                     end_lnum = 1;
                   }
                 }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_ml_comment _test_ctxt =
  let code =
    "@Java\n" ^
    "@@\n" ^
    "/* this is a *\n" ^
    "\n" ^
    "\n" ^
    "* multi line comment */method main() {}"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [];
                     start_lnum = 4;
                     end_lnum = 4;
                   }
                 }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_fxn_app _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { foo(); }"
  in
  let ast = Parser.parse code in
  let expected =  { AST.extension_fxns = [];
                    main_fxn =
                      { AST.id = "main";
                        stmts =
                          [(AST.ExprStmt
                              { AST.a =
                                  (Some { AST.a =
                                            (AST.FxnAppExpr (
                                                { AST.a = (AST.IdExpr "foo");
                                                  pos = { Position.lnum = 1; cnum = 19 } },
                                                []));
                                          pos = { Position.lnum = 1; cnum = 19 } });
                                pos = { Position.lnum = 1; cnum = 22 } })
                          ];
                        start_lnum = 1; end_lnum = 1 };
                    language = AST.Java }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_obj_call _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { j.someFxn(1, NORTH);  }"
  in
  let ast = Parser.parse code in
  let expected =  { AST.extension_fxns = [];
                    main_fxn =
                      { AST.id = "main";
                        stmts =
                          [(AST.ExprStmt
                              { AST.a =
                                  (Some { AST.a =
                                            (AST.BinOpExpr (
                                                { AST.a = (AST.IdExpr "j");
                                                  pos = { Position.lnum = 1; cnum = 17 } },
                                                AST.Dot,
                                                { AST.a =
                                                    (AST.FxnAppExpr (
                                                        { AST.a = (AST.IdExpr "someFxn");
                                                          pos = { Position.lnum = 1; cnum = 25 } },
                                                        [{ AST.a = (AST.IntExpr 1);
                                                           pos = { Position.lnum = 1; cnum = 27 } };
                                                         { AST.a = AST.NorthExpr;
                                                           pos = { Position.lnum = 1; cnum = 34 } }
                                                        ]
                                                      ));
                                                  pos = { Position.lnum = 1; cnum = 25 } }
                                              ));
                                          pos = { Position.lnum = 1; cnum = 18 } });
                                pos = { Position.lnum = 1; cnum = 36 } })
                          ];
                        start_lnum = 1; end_lnum = 1 };
                    language = AST.Java }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_negative_int _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { foo(-1); }"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       (AST.ExprStmt
                          { AST.a =
                              (Some { AST.a =
                                        (AST.FxnAppExpr (
                                            { AST.a = (AST.IdExpr "foo");
                                              pos = { Position.lnum = 1; cnum = 19 } },
                                            [{ AST.a = (AST.IntExpr (-1));
                                               pos = { Position.lnum = 1; cnum = 22 } }
                                            ]
                                          ));
                                      pos = { Position.lnum = 1; cnum = 19 } });
                            pos = { Position.lnum = 1; cnum = 24 } })
                     ];
                     start_lnum = 1;
                     end_lnum = 1;
                   }
                 }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_stmt_list _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { a.b(); c(); }"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.ExprStmt({
                           a = Some {
                               a = AST.BinOpExpr({
                                   a = AST.IdExpr("a");
                                   pos = { lnum = 1; cnum = 17 };
                                 }, AST.Dot, {
                                     a = AST.FxnAppExpr({
                                         a = AST.IdExpr("b");
                                         pos = { lnum = 1; cnum = 19 };
                                       }, []);
                                     pos = { lnum = 1; cnum = 19 };
                                   });
                               pos = { lnum = 1; cnum = 18 };
                             };
                           pos = { lnum = 1; cnum = 22 };
                         });
                       AST.ExprStmt({
                           a = Some {
                               a = AST.FxnAppExpr({
                                   a = AST.IdExpr("c");
                                   pos = { lnum = 1; cnum = 24 };
                                 }, []);
                               pos = { lnum = 1; cnum = 24 };
                             };
                           pos = { lnum = 1; cnum = 27 };
                         })
                     ];
                     start_lnum = 1;
                     end_lnum = 1;
                   }
                 }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_extension_method _test_ctxt =
  let code = "@Java\n" ^
             "method foo() {\n" ^
             "hop(); \n" ^
             "}\n" ^
             "@@\n" ^
             "method main() {\n" ^
             "hop();\n" ^
             "\n" ^
             "}"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.Java;
                   extension_fxns = [{
                       id = "foo";
                       stmts = [
                         AST.ExprStmt({
                             a = Some {
                                 a = AST.FxnAppExpr({
                                     a = AST.IdExpr("hop");
                                     pos = { lnum = 2; cnum = 3 };
                                   }, []);
                                 pos = { lnum = 2; cnum = 3 };
                               };
                             pos = { lnum = 2; cnum = 6 };
                           })
                       ];
                       start_lnum = 1;
                       end_lnum = 3;
                     }];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.ExprStmt({
                           a = Some {
                               a = AST.FxnAppExpr({
                                   a = AST.IdExpr("hop");
                                   pos = { lnum = 2; cnum = 3 };
                                 }, []);
                               pos = { lnum = 2; cnum = 3 };
                             };
                           pos = { lnum = 2; cnum = 6 };
                         })
                     ];
                     start_lnum = 1;
                     end_lnum = 4;
                   }
                 }
  in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_missing_semicolon _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { Jeroo j = new Jeroo() }"
  in
  assert_raises (Exceptions.CompileException {
      pos = { lnum = 1; cnum = 39 };
      pane = Pane.Main;
      exception_type = "error";
      message = "expected one of `;`, `.`, or an operator\n";
    }) (fun () -> Compiler.compile code)

(* TODO: complete all of these tasks in a future story *)
let parse_missing_rparen_in_expr _test_ctxt = ()

let parse_missing_rbrace _test_ctxt = ()

let parse_missing_rparen_in_fxn_app _test_ctxt = ()

let parse_missing_comma_in_fxn_app _test_ctxt = ()

let parse_lexing_error _test_ctxt = ()

let parse_empty_main_fxn _test_ctxt = ()

let parse_and_empty_rvalue _test_ctxt = ()

let parse_or_empty_rvalue _test_ctxt = ()

let parse_dot_empty_rvalue _test_ctxt = ()

let parse_not_empty_rvalue _test_ctxt = ()

let parse_new_empty_rvalue _test_ctxt = ()

let parse_malformed_if_stmt _test_ctxt = ()

let parse_malformed_while_stmt _test_ctxt = ()

let parse_wild_else_stmt _test_ctxt = ()

let suite =
  "Java Parsing">::: [
    "Parse Method">:: parse_method;
    "Parse Decl">:: parse_decl;
    "Parse If Stmt">:: parse_if_stmt;
    "Parse If Else Stmt">:: parse_if_else_stmt;
    "Parse Dangling Else">:: parse_dangling_if;
    "Parse While Stmt">:: parse_while_stmt;
    "Parse And">:: parse_and;
    "Parse Or">:: parse_or;
    "Parse Not">:: parse_not;
    "Parse Not Precedence">:: parse_not_precedence;
    "Parse Paren Precedence">:: parse_paren_precedence;
    "Parse comments">:: parse_comment;
    "Parse ml-comment">:: parse_ml_comment;
    "Parse Function Application">:: parse_fxn_app;
    "Parse obj call">:: parse_obj_call;
    "Parse Negative Int">:: parse_negative_int;
    "Parse Stmt List">:: parse_stmt_list;
    "Parse Extension Method">:: parse_extension_method;
    "Parse Missing Semicolon">:: parse_missing_semicolon;
    "Parse missing rparen in expr">:: parse_missing_rparen_in_expr;
    "Parse missing rbrace">:: parse_missing_rbrace;
    "Parse missing rparen in fxn app">:: parse_missing_rparen_in_fxn_app;
    "Parse missing comma in fxn app">:: parse_missing_comma_in_fxn_app;
    "Parse lexing error">:: parse_lexing_error;
    "Parse empty main fxn">:: parse_empty_main_fxn;
    "Parse and empty rvalue">:: parse_and_empty_rvalue;
    "Parse or empty rvalue">:: parse_or_empty_rvalue;
    "Parse dot empty rvalue">:: parse_dot_empty_rvalue;
    "Parse new empty rvalue">:: parse_new_empty_rvalue;
    "Parse malformed if stmt">:: parse_malformed_if_stmt;
    "Parse malformed while stmt">:: parse_malformed_while_stmt;
    "Parse wild else stmt">:: parse_while_stmt;
  ]
