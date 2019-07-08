open OUnit2
open Lib
open AST

let parse_string s =
  let lexbuf = Lexing.from_string s in
  PythonParser.translation_unit (PythonLexer.token (PythonLexerState.create())) lexbuf

let parse_empty _test_ctxt =
  let code = "@PYTHON\n"  ^
             "@@\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [];
                     start_lnum = 1;
                     end_lnum = 2;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_main _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "True\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.BlockStmt([
                           AST.ExprStmt({
                               a = Some {
                                   a = AST.TrueExpr;
                                   pos = { lnum = 1; cnum = 4 };
                                 };
                               pos = { lnum = 1; cnum = 5 };
                             });
                         ])
                     ];
                     start_lnum = 1;
                     end_lnum = 2;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_if _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "if True: True\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt {
                         a = ({
                             a = AST.TrueExpr;
                             pos = { lnum = 1; cnum = 7 };
                           }, AST.BlockStmt([
                             AST.ExprStmt({
                                 a = Some {
                                     a = TrueExpr;
                                     pos = { lnum = 1; cnum = 13 };
                                   };
                                 pos = { lnum = 1; cnum = 14 };
                               })
                           ]));
                         pos = { lnum = 1; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 2;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_if_else _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "if True:\n" ^
             "\t True\n" ^
             "else:\n" ^
             "\t False\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfElseStmt {
                         a = ({
                             a = AST.TrueExpr;
                             pos = { lnum = 1; cnum = 7 };
                           }, AST.BlockStmt([
                             AST.BlockStmt [
                               AST.ExprStmt({
                                   a = Some {
                                       a = TrueExpr;
                                       pos = { lnum = 2; cnum = 6 };
                                     };
                                   pos = { lnum = 2; cnum = 7 };
                                 })
                             ]]),
                             AST.BlockStmt([
                                 BlockStmt [
                                   AST.ExprStmt({
                                       a = Some {
                                           a = FalseExpr;
                                           pos = { lnum = 4; cnum = 7 };
                                         };
                                       pos = { lnum = 4; cnum = 8 };
                                     })]]));
                         pos = { lnum = 1; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 5;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_if_elif _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "if True: True\n" ^
             "elif False: False\n"
  in
  let ast  = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfElseStmt {
                         a = {
                           a = AST.TrueExpr;
                           pos = { lnum = 1; cnum = 7 };
                         }, AST.BlockStmt([
                             AST.ExprStmt({
                                 a = Some {
                                     a = TrueExpr;
                                     pos = { lnum = 1; cnum = 13 };
                                   };
                                 pos = { lnum = 1; cnum = 14 };
                               })
                           ]), AST.IfStmt {
                             a = ({
                                 a = AST.FalseExpr;
                                 pos = { lnum = 2; cnum = 10 };
                               }, AST.BlockStmt([
                                 AST.ExprStmt({
                                     a = Some {
                                         a = FalseExpr;
                                         pos = { lnum = 2; cnum = 17 };
                                       };
                                     pos = { lnum = 2; cnum = 18 };
                                   })
                               ]));
                             pos = { lnum = 2; cnum = 4 };
                           };
                         pos = { lnum = 1; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 3;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_if_elif_else _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "if True: True\n" ^
             "elif False: False\n" ^
             "else: True\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfElseStmt {
                         a = ({
                             a = AST.TrueExpr;
                             pos = { lnum = 1; cnum = 7 };
                           }, AST.BlockStmt([
                             AST.ExprStmt({
                                 a = Some {
                                     a = TrueExpr;
                                     pos = { lnum = 1; cnum = 13 };
                                   };
                                 pos = { lnum = 1; cnum = 14 };
                               })
                           ]), AST.IfElseStmt {
                             a = ({
                                 a = AST.FalseExpr;
                                 pos = { lnum = 2; cnum = 10 };
                               }, AST.BlockStmt([
                                 AST.ExprStmt({
                                     a = Some {
                                         a = FalseExpr;
                                         pos = { lnum = 2; cnum = 17 };
                                       };
                                     pos = { lnum = 2; cnum = 18 };
                                   })
                               ]), AST.BlockStmt([
                                 AST.ExprStmt({
                                     a = Some {
                                         a = TrueExpr;
                                         pos = { lnum = 3; cnum = 10 };
                                       };
                                     pos = { lnum = 3; cnum = 11 };
                                   })
                               ]));
                             pos = { lnum = 2; cnum = 4 };
                           });
                         pos = { lnum = 1; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 4;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_nested_if _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "if True:\n" ^
             "\tif False:\n" ^
             "\t\tFalse\n" ^
             "else:\n" ^
             "\tTrue\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfElseStmt {
                         a = ({
                             a = AST.TrueExpr;
                             pos = { lnum = 1; cnum = 7 };
                           }, AST.BlockStmt([
                             AST.IfStmt {
                               a = ({
                                   a = AST.FalseExpr;
                                   pos = { lnum = 2; cnum = 9 };
                                 }, AST.BlockStmt([
                                   AST.BlockStmt([
                                       ExprStmt {
                                         a = Some {
                                             a = FalseExpr;
                                             pos = { lnum = 3; cnum = 7 };
                                           };
                                         pos = { lnum = 3; cnum = 8 };
                                       }
                                     ])
                                 ]));
                               pos = { lnum = 2; cnum = 3 };
                             }
                           ]), AST.BlockStmt([
                             AST.BlockStmt([
                                 AST.ExprStmt({
                                     a = Some {
                                         a = TrueExpr;
                                         pos = { lnum = 5; cnum = 5 };
                                       };
                                     pos = { lnum = 5; cnum = 6 };
                                   })
                               ])
                           ]));
                         pos = { lnum = 1; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 6;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_while _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "while True: False\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.WhileStmt {
                         a = ({
                             a = AST.TrueExpr;
                             pos = { lnum = 1; cnum = 10 };
                           }, AST.BlockStmt([
                             AST.ExprStmt({
                                 a = Some {
                                     a = FalseExpr;
                                     pos = { lnum = 1; cnum = 17 };
                                   };
                                 pos = { lnum = 1; cnum = 18 };
                               })
                           ]));
                         pos = { lnum = 1; cnum = 5 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 2;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_and _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "if True and False: False\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt {
                         a = ({
                             a = BinOpExpr({
                                 a = TrueExpr;
                                 pos = { lnum = 1; cnum = 7 };
                               }, AST.And, {
                                   a = FalseExpr;
                                   pos = { lnum = 1; cnum = 17 };
                                 });
                             pos = { lnum = 1; cnum = 11 };
                           }, AST.BlockStmt([
                             AST.ExprStmt({
                                 a = Some {
                                     a = FalseExpr;
                                     pos = { lnum = 1; cnum = 24 };
                                   };
                                 pos = { lnum = 1; cnum = 25 };
                               })
                           ]));
                         pos = { lnum = 1; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 2;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_or _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "if True or False: False\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt {
                         a = ({
                             a = BinOpExpr({
                                 a = TrueExpr;
                                 pos = { lnum = 1; cnum = 0 };
                               }, AST.Or, {
                                   a = FalseExpr;
                                   pos = { lnum = 1; cnum = 0 };
                                 });
                             pos = { lnum = 1; cnum = 0 };
                           }, AST.BlockStmt([
                             AST.ExprStmt({
                                 a = Some {
                                     a = FalseExpr;
                                     pos = { lnum = 1; cnum = 0 };
                                   };
                                 pos = { lnum = 1; cnum = 0 };
                               })
                           ]));
                         pos = { lnum = 1; cnum = 0 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 2;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_not _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "if not True: False\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt {
                         a = ({
                             a = UnOpExpr(AST.Not, {
                                 a = TrueExpr;
                                 pos = { lnum = 1; cnum = 11 };
                               });
                             pos = { lnum = 1; cnum = 6 };
                           }, AST.BlockStmt([
                             AST.ExprStmt({
                                 a = Some {
                                     a = FalseExpr;
                                     pos = { lnum = 1; cnum = 18 };
                                   };
                                 pos = { lnum = 1; cnum = 19 };
                               })
                           ]));
                         pos = { lnum = 1; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 2;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_comment _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "#this is a comment###\n" ^
             "\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [];
                     start_lnum = 1;
                     end_lnum = 2;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_inline_comment _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "True #This is a comment too \n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.BlockStmt([
                           AST.ExprStmt({
                               a = Some {
                                   a = AST.TrueExpr;
                                   pos = { lnum = 1; cnum = 4 };
                                 };
                               pos = { lnum = 1; cnum = 29 };
                             });
                         ])
                     ];
                     start_lnum = 1;
                     end_lnum = 2;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_newlines _test_ctxt =
  let code = "@PYTHON\n\n\n\n\n\n@@\n\n\n\n\nTrue\n\n\n\n\n" in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.BlockStmt([
                           AST.ExprStmt({
                               a = Some {
                                   a = AST.TrueExpr;
                                   pos = { lnum = 5; cnum = 4 };
                                 };
                               pos = { lnum = 5; cnum = 9 };
                             });
                         ])
                     ];
                     start_lnum = 1;
                     end_lnum = 6;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_def _test_ctxt =
  let code = "@PYTHON\n" ^
             "def foo(self):\n" ^
             "\tself.hop()" ^
             "@@\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [
                     {
                       id = "foo";
                       stmts = [
                         AST.BlockStmt([
                             AST.ExprStmt({
                                 a = Some {
                                     a = FxnAppExpr({
                                         a = IdExpr("hop");
                                         pos = { lnum = 2; cnum = 9 };
                                       }, []);
                                     pos = { lnum = 2; cnum = 6 };
                                   };
                                 pos = { lnum = 2; cnum = 14 };
                               });
                           ])
                       ];
                       start_lnum = 1;
                       end_lnum = 1;
                     }
                   ];
                   main_fxn = {
                     id = "main";
                     stmts = [];
                     start_lnum = 1;
                     end_lnum = 2;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_fxn_application _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "foo(True, NORTH)\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.BlockStmt([
                           AST.ExprStmt({
                               a = Some {
                                   a = AST.FxnAppExpr({
                                       a = IdExpr("foo");
                                       pos = { lnum = 1; cnum = 3 };
                                     }, [
                                         {
                                           a = TrueExpr;
                                           pos = { lnum = 1; cnum = 8 };
                                         };
                                         {
                                           a = NorthExpr;
                                           pos = { lnum = 1; cnum = 15 };
                                         }
                                       ]);
                                   pos = { lnum = 1; cnum = 3 };
                                 };
                               pos = { lnum = 1; cnum = 17 };
                             });
                         ])
                     ];
                     start_lnum = 1;
                     end_lnum = 2;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_paren_precedence _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "if True and (True and True):True\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt {
                         a = ({
                             a = AST.BinOpExpr({
                                 a = AST.TrueExpr;
                                 pos = { lnum = 1; cnum = 7 };
                               }, AST.And, {
                                   a = AST.BinOpExpr({
                                       a = AST.TrueExpr;
                                       pos = { lnum = 1; cnum = 17 };
                                     }, AST.And, {
                                         a = AST.TrueExpr;
                                         pos = { lnum = 1; cnum = 26 };
                                       });
                                   pos = { lnum = 1; cnum = 21 };
                                 });
                             pos = { lnum = 1; cnum = 11 };
                           }, AST.BlockStmt [
                             AST.ExprStmt {
                               a = Some {
                                   a = TrueExpr;
                                   pos = { lnum = 1; cnum = 32 };
                                 };
                               pos = { lnum = 1; cnum = 33 };
                             }
                           ]);
                         pos = { lnum = 1; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 2;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_and_or_precedence _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "if True and True or True:True\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt {
                         a = ({
                             a = AST.BinOpExpr({
                                 a = BinOpExpr({
                                     a = TrueExpr;
                                     pos = { lnum = 1; cnum = 7 };
                                   }, AST.And, {
                                       a = TrueExpr;
                                       pos = { lnum = 1; cnum = 16 };
                                     });
                                 pos = { lnum = 1; cnum = 11 };
                               }, AST.Or, {
                                   a = TrueExpr;
                                   pos = { lnum = 1; cnum = 24 };
                                 });
                             pos = { lnum = 1; cnum = 19 };
                           }, AST.BlockStmt [
                             AST.ExprStmt {
                               a = Some {
                                   a = TrueExpr;
                                   pos = { lnum = 1; cnum = 29 };
                                 };
                               pos = { lnum = 1; cnum = 30 };
                             }
                           ]);
                         pos = { lnum = 1; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 2;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_not_precedence _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "if not True and True: True\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt {
                         a = ({
                             a = AST.BinOpExpr({
                                 a = AST.UnOpExpr(AST.Not, {
                                     a = AST.TrueExpr;
                                     pos = { lnum = 1; cnum = 11 };
                                   });
                                 pos = { lnum = 1; cnum = 6 };
                               }, AST.And, {
                                   a = AST.TrueExpr;
                                   pos = { lnum = 1; cnum = 20 };
                                 });
                             pos = { lnum = 1; cnum = 15 };
                           }, AST.BlockStmt [
                             AST.ExprStmt {
                               a = Some {
                                   a = TrueExpr;
                                   pos = { lnum = 1; cnum = 26 };
                                 };
                               pos = { lnum = 1; cnum = 27 };
                             }
                           ]);
                         pos = { lnum = 1; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 2;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_object_member_access _test_ctxt =
  let code = "@PYTHON\n" ^
             "@@\n" ^
             "a.b(1)\n"
  in
  let ast = parse_string code in
  let expected = { language = AST.Python;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       BlockStmt [
                         ExprStmt {
                           a = Some {
                               a = BinOpExpr({
                                   a = IdExpr("a");
                                   pos = { lnum = 1; cnum = 1 };
                                 }, Dot, {
                                     a = FxnAppExpr({
                                         a = IdExpr("b");
                                         pos = { lnum = 1; cnum = 3 };
                                       }, [
                                           {
                                             a = IntExpr(1);
                                             pos = { lnum = 1; cnum = 5 };
                                           }
                                         ]);
                                     pos = { lnum = 1; cnum = 3 };
                                   });
                               pos = { lnum = 1; cnum = 2 };
                             };
                           pos = { lnum = 1; cnum = 7 };
                         }
                       ]
                     ];
                     start_lnum = 1;
                     end_lnum = 2;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_syntax_error _test_ctxt =
  let code = "@PYTHON\n" ^
             "while\n" ^
             "@@\n"
  in

  assert_raises (Exceptions.CompileException {
      pos = { lnum = 1; cnum = 5 };
      pane = Pane.Extensions;
      exception_type = "error";
      message = "expected `def`\n";
    }) (fun () -> Compiler.compile code)

let suite =
  "Python Parsing">::: [
    "Parse empty">:: parse_empty;
    "Parse main">:: parse_main;
    "Parse if">:: parse_if;
    "Parse if else">:: parse_if_else;
    "Parse if elif">:: parse_if_elif;
    "Parse if elif else">:: parse_if_elif_else;
    "Parse nested if">::parse_nested_if;
    "Parse while">:: parse_while;
    "Parse and">:: parse_and;
    "Parse not">:: parse_not;
    "Parse comment">:: parse_comment;
    "Parse inline comment">:: parse_inline_comment;
    "Parse newlines">:: parse_newlines;
    "Parse def">:: parse_def;
    "Parse fxn application">:: parse_fxn_application;
    "Parse paren precedence">:: parse_paren_precedence;
    "Parse and or precedence">:: parse_and_or_precedence;
    "Parse not precedence">:: parse_not_precedence;
    "Parse object member access">:: parse_object_member_access;
    "Parse syntax error">:: parse_syntax_error;
  ]
