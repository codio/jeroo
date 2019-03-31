open OUnit2
open Lib
open AST

let parse_string s =
  let lexbuf = Lexing.from_string s in JavaParser.translation_unit JavaLexer.token lexbuf

let parse_method _test_ctxt =
  let code = "@Java\n @@\n method main() { }" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [];
      start_lnum = 1;
      end_lnum = 1;
    };
  } in
  assert_equal ast expected

let parse_decl _test_ctxt =
  let code = "@Java\n @@\n method main() { Jeroo j = new Jeroo(1, 2); }" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 1;
                  },
                    [
                      {
                        a = AST.IntExpr(1);
                        lnum = 1;
                      };
                      {
                        a = AST.IntExpr(2);
                        lnum = 1;
                      }
                    ]);
                lnum = 1;
              });
            lnum = 1;
          })
      ];
      start_lnum = 1;
      end_lnum = 1;
    };
  } in
  assert_equal ast expected

let parse_if_stmt _test_ctxt =
  let code = "@Java\n @@\n method main() { if (true) { } }" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.TrueExpr;
            lnum = 1;
          }, AST.BlockStmt [], 1)
      ];
      start_lnum = 1;
      end_lnum = 1;
    };
  } in
  assert_equal ast expected

let parse_if_else_stmt _test_ctxt =
  let code = "@Java\n @@\n method main() { if (true) { } else { }}" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfElseStmt({
            a = AST.TrueExpr;
            lnum = 1;
          }, AST.BlockStmt [], AST.BlockStmt [], 1);
      ];
      start_lnum = 1;
      end_lnum = 1;
    }
  } in
  assert_equal ast expected

let parse_dangling_if _test_ctxt =
  let code = "@Java\n @@\n method main() { if (true) if (false) {} else { }}" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.TrueExpr;
            lnum = 1;
          }, AST.IfElseStmt({
            a =AST.FalseExpr;
            lnum = 1;
          }, AST.BlockStmt [], AST.BlockStmt [], 1), 1);
      ];
      start_lnum = 1;
      end_lnum = 1;
    };
  } in
  assert_equal ast expected

let parse_while_stmt _test_ctxt =
  let code = "@Java\n @@\n method main() { while(true) { }}" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.WhileStmt({
            a = AST.TrueExpr;
            lnum = 1;
          }, AST.BlockStmt [], 1)
      ];
      start_lnum = 1;
      end_lnum = 1;
    };
  } in
  assert_equal ast expected

let parse_and _test_ctxt =
  let code = "@Java\n @@\n method main() { if (true && true) { }}" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [AST.IfStmt({
          a = AST.BinOpExpr({
              a = AST.TrueExpr;
              lnum = 1;
            }, AST.And, {
                a = AST.TrueExpr;
                lnum = 1;
              });
          lnum = 1;
        }, AST.BlockStmt [], 1)];
      start_lnum = 1;
      end_lnum = 1;
    };
  } in
  assert_equal ast expected

let parse_or _test_ctxt =
  let code = "@Java\n @@\n method main() { if (true || true) { }}" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.BinOpExpr({
                a = AST.TrueExpr;
                lnum = 1;
              }, AST.Or, {
                  a = AST.TrueExpr;
                  lnum = 1;
                });
            lnum = 1;
          }, AST.BlockStmt [], 1);
      ];
      start_lnum = 1;
      end_lnum = 1;
    }
  } in
  assert_equal ast expected

let parse_not _test_ctxt =
  let code = "@Java\n @@\n method main() { if (!true) {} }" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.UnOpExpr(AST.Not, {
                a = AST.TrueExpr;
                lnum = 1;
              });
            lnum = 1;
          }, AST.BlockStmt [], 1);
      ];
      start_lnum = 1;
      end_lnum = 1;
    }
  } in
  assert_equal ast expected

let parse_not_precedence _test_ctxt =
  let code = "@Java\n @@\n method main() { if (!true && false) {}}" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.BinOpExpr({
                a = AST.UnOpExpr(AST.Not, {
                    a = AST.TrueExpr;
                    lnum = 1;
                  });
                lnum = 1;
              }, AST.And, {
                  a = AST.FalseExpr;
                  lnum = 1;
                });
            lnum = 1;
          }, AST.BlockStmt [], 1);
      ];
      start_lnum = 1;
      end_lnum = 1;
    }
  } in
  assert_equal ast expected

let parse_paren_precedence _test_ctxt =
  let code = "@Java\n @@\n method main() { if (true && (false && false)) {} }" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.BinOpExpr({
                a = AST.TrueExpr;
                lnum = 1;
              }, AST.And, {
                  a = AST.BinOpExpr({
                      a = AST.FalseExpr;
                      lnum = 1;
                    }, AST.And, {
                        a = AST.FalseExpr;
                        lnum = 1;
                      });
                  lnum = 1;
                });
            lnum = 1;
          }, AST.BlockStmt [], 1)
      ];
      start_lnum = 1;
      end_lnum = 1;
    }
  } in
  assert_equal ast expected

let parse_comment _test_ctxt =
  let code = "// this is a comment\n @Java\n @@\n method main() { }" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [];
      start_lnum = 1;
      end_lnum = 1;
    }
  } in
  assert_equal ast expected

let parse_ml_comment _test_ctxt =
  let code = "@Java\n @@\n /* this is a *\n\n\n* multi line comment */method main() {}" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [];
      start_lnum = 4;
      end_lnum = 4;
    }
  } in
  assert_equal ast expected

let parse_fxn_app _test_ctxt =
  let code = "@Java\n @@\n method main() { foo(); }" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.ExprStmt({
            a = AST.FxnAppExpr({
                a = AST.IdExpr("foo");
                lnum = 1;
              }, []);
            lnum = 1;
          });
      ];
      start_lnum = 1;
      end_lnum = 1;
    }
  } in
  assert_equal ast expected

let parse_obj_call _test_ctxt =
  let code = "@Java\n @@\n method main() { j.someFxn(1, NORTH);  }" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.ExprStmt({
            a = AST.BinOpExpr({
                a = AST.IdExpr("j");
                lnum = 1;
              }, AST.Dot, {
                  a = AST.FxnAppExpr({
                      a = AST.IdExpr("someFxn");
                      lnum = 1;
                    }, [
                        {
                          a = AST.IntExpr(1);
                          lnum = 1;
                        };
                        {
                          a = AST.NorthExpr;
                          lnum = 1;
                        }
                      ]);
                  lnum = 1;
                });
            lnum = 1;
          })
      ];
      start_lnum = 1;
      end_lnum = 1;
    }
  } in
  assert_equal ast expected

let parse_negative_int _test_ctxt =
  let code = "@Java\n @@\n method main() { foo(-1); }" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.ExprStmt({
            a = AST.FxnAppExpr({
                a = AST.IdExpr("foo");
                lnum = 1;
              }, [{
                a = AST.IntExpr(-1);
                lnum = 1;
              }]);
            lnum = 1;
          })
      ];
      start_lnum = 1;
      end_lnum = 1;
    }
  } in
  assert_equal ast expected

let parse_stmt_list _test_ctxt =
  let code = "@Java\n @@\n method main() { a.b(); c(); }" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.ExprStmt({
            a = AST.BinOpExpr({
                a = AST.IdExpr("a");
                lnum = 1;
              }, AST.Dot, {
                  a = AST.FxnAppExpr({
                      a = AST.IdExpr("b");
                      lnum = 1;
                    }, []);
                  lnum = 1;
                });
            lnum = 1;
          });
        AST.ExprStmt({
            a = AST.FxnAppExpr({
                a = AST.IdExpr("c");
                lnum = 1;
              }, []);
            lnum = 1;
          })
      ];
      start_lnum = 1;
      end_lnum = 1;
    }
  } in
  assert_equal ast expected

let parse_extension_method _test_ctxt =
  let code = "@Java\n method foo() {\n hop(); \n}\n @@\n method main() {\n hop();\n \n}" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [{
        id = "foo";
        stmts = [
          AST.ExprStmt({
              a = AST.FxnAppExpr({
                  a = AST.IdExpr("hop");
                  lnum = 2;
                }, []);
              lnum = 2;
            })
        ];
        start_lnum = 1;
        end_lnum = 3;
      }];
    main_fxn = {
      id = "main";
      stmts = [
        AST.ExprStmt {
          a = AST.FxnAppExpr({
              a = AST.IdExpr("hop");
              lnum = 2;
            }, []);
          lnum = 2;
        }
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  assert_equal ast expected

let parse_syntax_error _test_ctxt =
  let code = "@Java\n@@\n method main() { Jeroo j = new Jeroo() }" in
  assert_raises (Compiler.ParserException {
      message = "expected ';' at the end of declaration\n";
      lnum = 1
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
