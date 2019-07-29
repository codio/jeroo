open OUnit2
open Lib
open AST

let parse_method _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [];
                     start_lnum = 1;
                     end_lnum = 2;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_decl _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "dim j as jeroo = new jeroo(1, 2)\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.DeclStmt("Jeroo", "j", {
                           a = AST.UnOpExpr(AST.New, {
                               a = AST.FxnAppExpr({
                                   a = AST.IdExpr("Jeroo");
                                   pos = { lnum = 2; cnum = 26 };
                                 }, [
                                     {
                                       a = AST.IntExpr(1);
                                       pos = { lnum = 2; cnum = 28 };
                                     };
                                     {
                                       a = AST.IntExpr(2);
                                       pos = { lnum = 2; cnum = 31 };
                                     };
                                   ]);
                               pos = { lnum = 2; cnum = 26 };
                             });
                           pos = { lnum = 2; cnum = 20 };
                         })
                     ];
                     start_lnum = 1;
                     end_lnum = 3;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_if_stmt _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "if (true) then\n" ^
             "end if\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt
                         { a = ({
                               a = AST.TrueExpr;
                               pos = { lnum = 2; cnum = 8 };
                             }, AST.BlockStmt []);
                           pos = { lnum = 2; cnum = 2 };
                         }
                     ];
                     start_lnum = 1;
                     end_lnum = 4;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_if_stmt_no_paren _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "if true then\n" ^
             "end if\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt
                         { a = ({
                               a = AST.TrueExpr;
                               pos = { lnum = 2; cnum = 7 };
                             }, AST.BlockStmt []);
                           pos = { lnum = 2; cnum = 2 };
                         }
                     ];
                     start_lnum = 1;
                     end_lnum = 4;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_elseif_stmt _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "if (true) then\n" ^
             "elseif (false) then\n" ^
             "end if\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfElseStmt {
                         a = ({
                             a = AST.TrueExpr;
                             pos = { lnum = 2; cnum = 8 };
                           }, AST.BlockStmt [], AST.IfStmt
                               { a = ({
                                     a = AST.FalseExpr;
                                     pos = { lnum = 3; cnum = 13 };
                                   }, AST.BlockStmt []);
                                 pos = { lnum = 3; cnum = 6 };
                               });
                         pos = { lnum = 2; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 5;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_elseif_no_paren_stmt _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "if true then\n" ^
             "elseif false then\n" ^
             "end if\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfElseStmt {
                         a = ({
                             a = AST.TrueExpr;
                             pos = { lnum = 2; cnum = 7 };
                           }, AST.BlockStmt [], AST.IfStmt {
                             a = ({
                                 a = AST.FalseExpr;
                                 pos = { lnum = 3; cnum = 12 };
                               }, AST.BlockStmt []);
                             pos = { lnum = 3; cnum = 6 };
                           });
                         pos = { lnum = 2; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 5;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_elseif_list_stmt _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "if (true) then\n" ^
             "elseif (false) then\n" ^
             "elseif (true) then\n" ^
             "else\n" ^
             "end if\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfElseStmt {
                         a = {
                           a = AST.TrueExpr;
                           pos = { lnum = 2; cnum = 8 };
                         }, AST.BlockStmt [], AST.IfElseStmt {
                             a = ({
                                 a = AST.FalseExpr;
                                 pos = { lnum = 3; cnum = 13 };
                               }, AST.BlockStmt [], AST.IfElseStmt {
                                 a = ({
                                     a = AST.TrueExpr;
                                     pos = { lnum = 4; cnum = 12 };
                                   }, AST.BlockStmt [], AST.BlockStmt []);
                                 pos = { lnum = 4; cnum = 6 };
                               });
                             pos = { lnum = 3; cnum = 6 };
                           };
                         pos = { lnum = 2; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 7;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_elseif_list_no_paren_stmt _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "if true then\n" ^
             "elseif false then\n" ^
             "elseif true then\n" ^
             "else\n end if\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfElseStmt {
                         a = {
                           a = AST.TrueExpr;
                           pos = { lnum = 2; cnum = 7 };
                         }, AST.BlockStmt [], AST.IfElseStmt {
                             a = {
                               a = AST.FalseExpr;
                               pos = { lnum = 3; cnum = 12 };
                             }, AST.BlockStmt [], AST.IfElseStmt {
                                 a = {
                                   a = AST.TrueExpr;
                                   pos = { lnum = 4; cnum = 11 };
                                 }, AST.BlockStmt [], AST.BlockStmt [];
                                 pos = { lnum = 4; cnum = 6 };
                               };
                             pos = { lnum = 3; cnum = 6 };
                           };
                         pos = { lnum = 2; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 7;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_while_stmt _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "while (true)\n" ^
             "end while\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.WhileStmt {
                         a = ({
                             a = AST.TrueExpr;
                             pos = { lnum = 2; cnum = 11 };
                           }, AST.BlockStmt []);
                         pos = { lnum = 2; cnum = 5 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 4;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_while_no_paren _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "while true\n" ^
             "end while\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.WhileStmt {
                         a = ({
                             a = AST.TrueExpr;
                             pos = { lnum = 2; cnum = 10 };
                           }, AST.BlockStmt []);
                         pos = { lnum = 2; cnum = 5 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 4;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_and _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "if true and true then\n" ^
             "end if\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt {
                         a = ({
                             a = AST.BinOpExpr({
                                 a = AST.TrueExpr;
                                 pos = { lnum = 2; cnum = 7 };
                               }, AST.And, {
                                   a = AST.TrueExpr;
                                   pos = { lnum = 2; cnum = 16 };
                                 });
                             pos = { lnum = 2; cnum = 11 };
                           }, AST.BlockStmt []);
                         pos = { lnum = 2; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 4;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_or _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "if true or true then\n" ^
             "end if\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt{
                         a = ({
                             a = AST.BinOpExpr({
                                 a = AST.TrueExpr;
                                 pos = { lnum = 2; cnum = 7 };
                               }, AST.Or, {
                                   a = AST.TrueExpr;
                                   pos = { lnum = 2; cnum = 15 };
                                 });
                             pos = { lnum = 2; cnum = 10 };
                           }, AST.BlockStmt []);
                         pos = { lnum = 2; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 4;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_not _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "if not false then\n" ^
             "end if\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt {
                         a = ({
                             a = AST.UnOpExpr(AST.Not, {
                                 a = AST.FalseExpr;
                                 pos = { lnum = 2; cnum = 12 };
                               });
                             pos = { lnum = 2; cnum = 6 };
                           }, AST.BlockStmt []);
                         pos = { lnum = 2; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 4;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_comment _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "'asdfasdf\n" ^
             "sub main()\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [];
                     start_lnum = 2;
                     end_lnum = 3;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_fxn_call _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "foobar(20, five, north)\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.ExprStmt({
                           a = Some({
                               a = AST.FxnAppExpr({
                                   a = AST.IdExpr("foobar");
                                   pos = { lnum = 2; cnum = 6 };
                                 }, [
                                     {
                                       a = AST.IntExpr(20);
                                       pos = { lnum = 2; cnum = 9 };
                                     };
                                     {
                                       a = AST.IdExpr("five");
                                       pos = { lnum = 2; cnum = 15 };
                                     };
                                     {
                                       a = AST.NorthExpr;
                                       pos = { lnum = 2; cnum = 22 };
                                     }
                                   ]);
                               pos = { lnum = 2; cnum = 6 };
                             });
                           pos = { lnum = 2; cnum = 0 };
                         })
                     ];
                     start_lnum = 1;
                     end_lnum = 3;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_obj_fxn_call _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "foo.bar(AHEAD)\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.ExprStmt({
                           a = Some {
                               a = AST.BinOpExpr({
                                   a = AST.IdExpr("foo");
                                   pos = { lnum = 2; cnum = 3 };
                                 }, AST.Dot, {
                                     a = AST.FxnAppExpr({
                                         a = AST.IdExpr("bar");
                                         pos = { lnum = 2; cnum = 7 };
                                       }, [{
                                         a = AST.AheadExpr;
                                         pos = { lnum = 2; cnum = 13 };
                                       }]);
                                     pos = { lnum = 2; cnum = 7 };
                                   });
                               pos = { lnum = 2; cnum = 4 };
                             };
                           pos = { lnum = 2; cnum = 0 };
                         })
                     ];
                     start_lnum = 1;
                     end_lnum = 3;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_not_precedence _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "if true and not false then\n" ^
             "end if\n"  ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt {
                         a = ({
                             a = AST.BinOpExpr({
                                 a = AST.TrueExpr;
                                 pos = { lnum = 2; cnum = 7 };
                               }, AST.And, {
                                   a = AST.UnOpExpr(AST.Not, {
                                       a = AST.FalseExpr;
                                       pos = { lnum = 2; cnum = 21 };
                                     });
                                   pos = { lnum = 2; cnum = 15 };
                                 });
                             pos = { lnum = 2; cnum = 11 };
                           }, AST.BlockStmt []);
                         pos = { lnum = 2; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 4;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_paren_precedence _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "if not (true and false) then\n" ^
             "end if\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt {
                         a = ({
                             a = AST.UnOpExpr(AST.Not, {
                                 a = AST.BinOpExpr({
                                     a = AST.TrueExpr;
                                     pos = { lnum = 2; cnum = 12 };
                                   }, AST.And, {
                                       a = AST.FalseExpr;
                                       pos = { lnum = 2; cnum = 22 };
                                     });
                                 pos = { lnum = 2; cnum = 16 };
                               });
                             pos = { lnum = 2; cnum = 6 };
                           }, AST.BlockStmt []);
                         pos = { lnum = 2; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 4;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_and_or_precedence _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "if true or false and true then\n" ^
             "end if\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt {
                         a = ({
                             a = AST.BinOpExpr({
                                 a = AST.TrueExpr;
                                 pos = { lnum = 2; cnum = 7 };
                               }, AST.Or, {
                                   a = AST.BinOpExpr({
                                       a = AST.FalseExpr;
                                       pos = { lnum = 2; cnum = 16 };
                                     }, AST.And, {
                                         a = AST.TrueExpr;
                                         pos = { lnum = 2; cnum = 25 };
                                       });
                                   pos = { lnum = 2; cnum = 20 };
                                 });
                             pos = { lnum = 2; cnum = 10 };
                           }, AST.BlockStmt []);
                         pos = { lnum = 2; cnum = 2 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 4;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_arbitrary_newlines _test_ctxt =
  let code = "@VB\n" ^
             "\n" ^
             "@@\n" ^
             "\n" ^
             "\n" ^
             "sub main()" ^
             "\n" ^
             "\n" ^
             "\n" ^
             "\n" ^
             "end sub\n" ^
             "\n" ^
             "\n"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                     ];
                     start_lnum = 3;
                     end_lnum = 7;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_fxn_list _test_ctxt =
  let code = "@VB\n" ^
             "sub foo()\n" ^
             "end sub\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "end sub\n" ^
             "\n" ^
             "\n"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [
                     {
                       id = "foo";
                       stmts = [];
                       start_lnum = 1;
                       end_lnum = 2;
                     }
                   ];
                   main_fxn = {
                     id = "main";
                     stmts = [];
                     start_lnum = 1;
                     end_lnum = 2;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_stmt_list _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "if true then\n" ^
             "end if\n" ^
             "while (true)\n" ^
             "end while\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.IfStmt {
                         a = ({
                             a = AST.TrueExpr;
                             pos = { lnum = 2; cnum = 7 };
                           }, AST.BlockStmt []);
                         pos = { lnum = 2; cnum = 2 };
                       };
                       AST.WhileStmt {
                         a = ({
                             a = AST.TrueExpr;
                             pos = { lnum = 4; cnum = 11 };
                           }, AST.BlockStmt []);
                         pos = { lnum = 4; cnum = 5 };
                       }
                     ];
                     start_lnum = 1;
                     end_lnum = 6;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

let parse_negative_int _test_ctxt =
  let code = "@VB\n" ^
             "@@\n" ^
             "sub main()\n" ^
             "foo(-1)\n" ^
             "end sub"
  in
  let ast = Parser.parse code in
  let expected = { language = AST.VB;
                   extension_fxns = [];
                   main_fxn = {
                     id = "main";
                     stmts = [
                       AST.ExprStmt({
                           a = Some {
                               a = AST.FxnAppExpr({
                                   a = AST.IdExpr("foo");
                                   pos = { lnum = 2; cnum = 3 };
                                 }, [{
                                   a = AST.IntExpr(-1);
                                   pos = { lnum = 2; cnum = 6 };
                                 }]);
                               pos = { lnum = 2; cnum = 3 };
                             };
                           pos = { lnum = 2; cnum = 0 };
                         })
                     ];
                     start_lnum = 1;
                     end_lnum = 3;
                   }
                 } in
  assert_equal ~printer:[%show: AST.translation_unit] expected ast

(* TODO: complete all of these tasks in a future story *)
let parse_missing_end_sub _test_ctxt = ()

let parse_missing_end_while _test_ctxt = ()

let parse_missing_end_if _test_ctxt = ()

let parse_missing_main_fxn _test_ctxt = ()

let parse_lexing_error _test_ctxt = ()

let parse_malformed_while_stmt _test_ctxt = ()

let parse_malformed_if_stmt _test_ctxt = ()

let parse_missing_newline_after_stmt _test_ctxt = ()

let parse_missing_rparen_in_expr _test_ctxt = ()

let parse_and_empty_rvalue _test_ctxt = ()

let parse_or_empty_rvalue _test_ctxt = ()

let parse_dot_empty_rvalue _test_ctxt = ()

let parse_not_empty_rvalue _test_ctxt = ()

let parse_dim_empty_rvalue _test_ctxt = ()

let parse_wild_else_stmt _test_ctxt = ()

let parse_missing_rparen_in_fxn_app _test_ctxt = ()

let parse_missing_comma_in_fxn_app _test_ctxt = ()

let suite =
  "Visual Basic Parsing">::: [
    "Parse Method">:: parse_method;
    "Parse Decl">:: parse_decl;
    "Parse If">:: parse_if_stmt;
    "Parse If No Paren">:: parse_if_stmt_no_paren;
    "Parse ElseIf">:: parse_elseif_stmt;
    "Parse ElseIf No Paren">:: parse_elseif_no_paren_stmt;
    "Parse ElseIf List">:: parse_elseif_list_stmt;
    "Parse ElseIf List No Paren">:: parse_elseif_list_no_paren_stmt;
    "Parse While">:: parse_while_stmt;
    "Parse While No Paren">:: parse_while_no_paren;
    "Parse And">:: parse_and;
    "Parse Or">:: parse_or;
    "Parse Not">:: parse_not;
    "Parse Comment">:: parse_comment;
    "Parse Function Call">:: parse_fxn_call;
    "Parse Object Function Call">:: parse_obj_fxn_call;
    "Parse Not Precedence">:: parse_not_precedence;
    "Parse Parenthesis Precedence">:: parse_paren_precedence;
    "Parse And Or Precedence">:: parse_and_or_precedence;
    "Parse Arbitrary Newlines">:: parse_arbitrary_newlines;
    "Parse fxn list">:: parse_fxn_list;
    "Parse Stmt List">:: parse_stmt_list;
    "Parse negative int">:: parse_negative_int;
    "Parse missing end sub">:: parse_missing_end_sub;
    "Parse missing end while">:: parse_missing_end_while;
    "Parse missing end if">:: parse_missing_end_if;
    "Parse missing main fxn">:: parse_missing_end_if;
    "Parse lexing error">:: parse_lexing_error;
    "Parse malformed while stmt">:: parse_malformed_while_stmt;
    "Parse malformed if stmt">:: parse_malformed_if_stmt;
    "Parse missing newline after stmt">:: parse_missing_newline_after_stmt;
    "Parse missing rparen in expr">:: parse_missing_rparen_in_expr;
    "Parse and empty rvalue">:: parse_and_empty_rvalue;
    "Parse or empty rvalue">:: parse_or_empty_rvalue;
    "Parse dot empty rvalue">:: parse_dot_empty_rvalue;
    "Parse not empty rvalue">:: parse_not_empty_rvalue;
    "Parse dim empty rvalue">:: parse_dim_empty_rvalue;
    "Parse wild else stmt">:: parse_wild_else_stmt;
    "Parse missing rparen in fxn app">:: parse_missing_rparen_in_fxn_app;
    "Parse missing comma in fxn app">:: parse_missing_comma_in_fxn_app;
  ]
