open OUnit2
open Lib
open AST

let parse_string s =
  let lexbuf = Lexing.from_string s in
  JavaParser.translation_unit (JavaLexer.token (JavaLexerState.create ())) lexbuf

let parse_method _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { }"
  in
  let ast = parse_string code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [];
                     start_lnum = 1;
                     end_lnum = 1;
                   };
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] ast expected

let parse_decl _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { Jeroo j = new Jeroo(1, 2); }"
  in
  let ast = parse_string code in
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
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_if_stmt _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { if (true) { } }"
  in
  let ast = parse_string code in
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
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_if_else_stmt _test_ctxt =
  let code = "@Java\n @@\n method main() { if (true) { } else { }}" in
  let ast = parse_string code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfElseStmt
                         { a = ({ a = AST.TrueExpr;
                                  pos = { lnum = 1; cnum = 25 };
                                }, AST.BlockStmt [], AST.BlockStmt []);
                           pos = { lnum = 1; cnum = 19 };
                         }
                     ];
                     start_lnum = 1;
                     end_lnum = 1;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_dangling_if _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { if (true) if (false) {} else { }}"
  in
  let ast = parse_string code in
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
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_while_stmt _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { while(true) { }}"
  in
  let ast = parse_string code in
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
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_and _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { if (true && true) { }}"
  in
  let ast = parse_string code in
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
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_or _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { if (true || true) { }}"
  in
  let ast = parse_string code in
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
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_not _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { if (!true) {} }"
  in
  let ast = parse_string code in
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
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_not_precedence _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { if (!true && false) {}}"
  in
  let ast = parse_string code in
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
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_paren_precedence _test_ctxt =
  let code = "@Java\n @@\n method main() { if (true && (false && false)) {} }" in
  let ast = parse_string code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt
                         { a = ({
                               a = AST.BinOpExpr({
                                   a = AST.TrueExpr;
                                   pos = { lnum = 1; cnum = 25 };
                                 }, AST.And, {
                                     a = AST.BinOpExpr({
                                         a = AST.FalseExpr;
                                         pos = { lnum = 1; cnum = 35 };
                                       }, AST.And, {
                                           a = AST.FalseExpr;
                                           pos = { lnum = 1; cnum = 44 };
                                         });
                                     pos = { lnum = 1; cnum = 38 };
                                   });
                               pos = { lnum = 1; cnum = 28 };
                             }, AST.BlockStmt []);
                           pos = { lnum = 1; cnum = 19 };
                         };
                     ];
                     start_lnum = 1;
                     end_lnum = 1;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_comment _test_ctxt =
  let code = "// this is a comment\n @Java\n @@\n method main() { }" in
  let ast = parse_string code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [];
                     start_lnum = 1;
                     end_lnum = 1;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_ml_comment _test_ctxt =
  let code = "@Java\n @@\n /* this is a *\n\n\n* multi line comment */method main() {}" in
  let ast = parse_string code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [];
                     start_lnum = 4;
                     end_lnum = 4;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_fxn_app _test_ctxt =
  let code = "@Java\n @@\n method main() { foo(); }" in
  let ast = parse_string code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.ExprStmt({
                           a = Some({
                               a = AST.FxnAppExpr({
                                   a = AST.IdExpr("foo");
                                   pos = { lnum = 1; cnum = 20 };
                                 }, []);
                               pos = { lnum = 1; cnum = 20 };
                             });
                           pos = { lnum = 1; cnum = 23 };
                         })
                     ];
                     start_lnum = 1;
                     end_lnum = 1;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_obj_call _test_ctxt =
  let code = "@Java\n @@\n method main() { j.someFxn(1, NORTH);  }" in
  let ast = parse_string code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.ExprStmt({
                           a = Some {
                               a = (AST.BinOpExpr({
                                   a = AST.IdExpr("j");
                                   pos = { lnum = 1; cnum = 18 };
                                 }, AST.Dot, {
                                     a = AST.FxnAppExpr({
                                         a = AST.IdExpr("someFxn");
                                         pos = { lnum = 1; cnum = 26 };
                                       }, [
                                           {
                                             a = AST.IntExpr(1);
                                             pos = { lnum = 1; cnum = 28 };
                                           };
                                           {
                                             a = AST.NorthExpr;
                                             pos = { lnum = 1; cnum = 35 };
                                           }
                                         ]);
                                     pos = { lnum = 1; cnum = 26 };
                                   })
                                 );
                               pos = { lnum = 1; cnum = 19 };
                             };
                           pos = { lnum = 1; cnum = 37 };
                         })
                     ];
                     start_lnum = 1;
                     end_lnum = 1;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_negative_int _test_ctxt =
  let code = "@Java\n @@\n method main() { foo(-1); }" in
  let ast = parse_string code in
  let expected = { language = AST.Java;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.ExprStmt({
                           a = Some {
                               a = AST.FxnAppExpr({
                                   a = AST.IdExpr("foo");
                                   pos = { lnum = 1; cnum = 20 };
                                 }, [{
                                   a = AST.IntExpr(-1);
                                   pos = { lnum = 1; cnum = 23 };
                                 }]);
                               pos = { lnum = 1; cnum = 20 };
                             };
                           pos = { lnum = 1; cnum = 25 };
                         })
                     ];
                     start_lnum = 1;
                     end_lnum = 1;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_stmt_list _test_ctxt =
  let code = "@Java\n" ^
             "@@\n" ^
             "method main() { a.b(); c(); }"
  in
  let ast = parse_string code in
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
                 } in
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
  let ast = parse_string code in
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
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_syntax_error _test_ctxt =
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
    "Parse Syntax Error">:: parse_syntax_error;
  ]
