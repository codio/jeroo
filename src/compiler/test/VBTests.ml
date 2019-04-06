open OUnit2
open Lib
open AST

let parse_string s =
  let lexbuf = Lexing.from_string s in
  VBParser.translation_unit VBLexer.token lexbuf

let parse_method _test_ctxt =
  let code = "@VB\n @@\n sub main() \n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [];
      start_lnum = 1;
      end_lnum = 2;
    }
  } in
  assert_equal ast expected

let parse_decl _test_ctxt =
  let code = "@VB\n @@\n sub main() \n dim j as jeroo = new jeroo(1, 2) \n end sub" in
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
                    lnum = 2;
                  }, [
                      {
                        a = AST.IntExpr(1);
                        lnum = 2;
                      };
                      {
                        a = AST.IntExpr(2);
                        lnum = 2;
                      };
                    ]);
                lnum = 2;
              });
            lnum = 2;
          })
      ];
      start_lnum = 1;
      end_lnum = 3;
    }
  } in
  assert_equal ast expected

let parse_if_stmt _test_ctxt =
  let code = "@VB\n @@\n sub main() \n if (true) then \n end if \n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.TrueExpr;
            lnum = 2;
          }, AST.BlockStmt [], 2)
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  assert_equal ast expected

let parse_if_stmt_no_paren _test_ctxt =
  let code = "@VB\n @@\n sub main() \n if true then \n end if \n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.TrueExpr;
            lnum = 2;
          }, AST.BlockStmt [], 2)
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  assert_equal ast expected

let parse_elseif_stmt _test_ctxt =
  let code = "@VB\n @@\n sub main()\n if (true) then\n elseif (false) then\n end if\n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfElseStmt({
            a = AST.TrueExpr;
            lnum = 2;
          }, AST.BlockStmt [], AST.IfStmt({
            a = AST.FalseExpr;
            lnum = 3;
          }, AST.BlockStmt [], 3), 2)
      ];
      start_lnum = 1;
      end_lnum = 5;
    }
  } in
  assert_equal ast expected

let parse_elseif_no_paren_stmt _test_ctxt =
  let code = "@VB\n @@\n sub main()\n if true then\n elseif false then\n end if\n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfElseStmt({
            a = AST.TrueExpr;
            lnum = 2;
          }, AST.BlockStmt [], AST.IfStmt({
            a = AST.FalseExpr;
            lnum = 3;
          }, AST.BlockStmt [], 3), 2)
      ];
      start_lnum = 1;
      end_lnum = 5;
    }
  } in
  assert_equal ast expected

let parse_elseif_list_stmt _test_ctxt =
  let code = "@VB\n @@\n sub main()\n if (true) then\n elseif (false) then\n elseif (true) then\n else\n end if\n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfElseStmt({
            a = AST.TrueExpr;
            lnum = 2;
          }, AST.BlockStmt [], AST.IfElseStmt({
            a = AST.FalseExpr;
            lnum = 3;
          }, AST.BlockStmt [], AST.IfElseStmt({
            a = AST.TrueExpr;
            lnum = 4;
          }, AST.BlockStmt [], AST.BlockStmt [], 4), 3), 2)
      ];
      start_lnum = 1;
      end_lnum = 7;
    }
  } in
  assert_equal ast expected

let parse_elseif_list_no_paren_stmt _test_ctxt =
  let code = "@VB\n @@\n sub main()\n if true then\n elseif false then\n elseif true then\n else\n end if\n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfElseStmt({
            a = AST.TrueExpr;
            lnum = 2;
          }, AST.BlockStmt [], AST.IfElseStmt({
            a = AST.FalseExpr;
            lnum = 3;
          }, AST.BlockStmt [], AST.IfElseStmt({
            a = AST.TrueExpr;
            lnum = 4;
          }, AST.BlockStmt [], AST.BlockStmt [], 4), 3), 2)
      ];
      start_lnum = 1;
      end_lnum = 7;
    }
  } in
  assert_equal ast expected

let parse_while_stmt _test_ctxt =
  let code = "@VB\n @@\n sub main() \n while (true) \n end while \n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.WhileStmt({
            a = AST.TrueExpr;
            lnum = 2;
          }, AST.BlockStmt [], 2)
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  assert_equal ast expected

let parse_while_no_paren _test_ctxt =
  let code = "@VB\n @@\n sub main() \n while true \n end while \n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.WhileStmt({
            a = AST.TrueExpr;
            lnum = 2;
          }, AST.BlockStmt [], 2)
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  assert_equal ast expected

let parse_and _test_ctxt =
  let code = "@VB\n @@\n sub main() \n if true and true then \n end if \n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.BinOpExpr({
                a = AST.TrueExpr;
                lnum = 2;
              }, AST.And, {
                  a = AST.TrueExpr;
                  lnum = 2;
                });
            lnum = 2;
          }, AST.BlockStmt [], 2)
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  assert_equal ast expected

let parse_or _test_ctxt =
  let code = "@VB\n @@\n sub main() \n if true or true then \n end if \n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.BinOpExpr({
                a = AST.TrueExpr;
                lnum = 2;
              }, AST.Or, {
                  a = AST.TrueExpr;
                  lnum = 2;
                });
            lnum = 2;
          }, AST.BlockStmt [], 2)
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  assert_equal ast expected

let parse_not _test_ctxt =
  let code = "@VB\n @@\n sub main() \n if not false then \n end if \n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.UnOpExpr(AST.Not, {
                a = AST.FalseExpr;
                lnum = 2;
              });
            lnum = 2;
          }, AST.BlockStmt [], 2)
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  assert_equal ast expected

let parse_comment _test_ctxt =
  let code = "@VB\n @@\n 'asdfasdf \n sub main() \n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [];
      start_lnum = 2;
      end_lnum = 3;
    }
  } in
  assert_equal ast expected

let parse_fxn_call _test_ctxt =
  let code = "@VB\n @@\n sub main() \n foobar(20, five, north) \n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.ExprStmt({
            a = Some({
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("foobar");
                    lnum = 2;
                  }, [
                      {
                        a = AST.IntExpr(20);
                        lnum = 2;
                      };
                      {
                        a = AST.IdExpr("five");
                        lnum = 2;
                      };
                      {
                        a = AST.NorthExpr;
                        lnum = 2;
                      }
                    ]);
                lnum = 2;
              });
            lnum = 2;
          })
      ];
      start_lnum = 1;
      end_lnum = 3;
    }
  } in
  assert_equal ast expected

let parse_obj_fxn_call _test_ctxt =
  let code = "@VB\n @@\n sub main() \n foo.bar(AHEAD) \n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("foo");
                    lnum = 2;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("bar");
                          lnum = 2;
                        }, [{
                          a = AST.AheadExpr;
                          lnum = 2;
                        }]);
                      lnum = 2
                    });
                lnum = 2;
              };
            lnum = 2;
          })
      ];
      start_lnum = 1;
      end_lnum = 3;
    }
  } in
  assert_equal ast expected

let parse_not_precedence _test_ctxt =
  let code = "@VB\n @@\n sub main()\n if true and not false then\n end if\n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.BinOpExpr({
                a = AST.TrueExpr;
                lnum = 2;
              }, AST.And, {
                  a = AST.UnOpExpr(AST.Not, {
                      a = AST.FalseExpr;
                      lnum = 2;
                    });
                  lnum = 2;
                });
            lnum = 2;
          }, AST.BlockStmt [], 2)
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  assert_equal ast expected

let parse_paren_precedence _test_ctxt =
  let code = "@VB\n @@\n sub main()\n if not (true and false) then\n end if\n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.UnOpExpr(AST.Not, {
                a = AST.BinOpExpr({
                    a = AST.TrueExpr;
                    lnum = 2;
                  }, AST.And, {
                      a = AST.FalseExpr;
                      lnum = 2;
                    });
                lnum = 2;
              });
            lnum = 2
          }, AST.BlockStmt [], 2)
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  assert_equal ast expected

let parse_and_or_precedence _test_ctxt =
  let code = "@VB\n @@\n sub main()\n if true or false and true then\n end if\n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.BinOpExpr({
                a = AST.TrueExpr;
                lnum = 2;
              }, AST.Or, {
                  a = AST.BinOpExpr({
                      a = AST.FalseExpr;
                      lnum = 2;
                    }, AST.And, {
                        a = AST.TrueExpr;
                        lnum = 2;
                      });
                  lnum = 2;
                });
            lnum = 2;
          }, AST.BlockStmt [], 2)
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  assert_equal ast expected

let parse_arbitrary_newlines _test_ctxt =
  let code = "@VB\n\n @@\n\n\n sub main()\n\n\n\n end sub\n   \n   \n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.ExprStmt({
            a = None;
            lnum = 4;
          });
        AST.ExprStmt({
            a = None;
            lnum = 5;
          });
        AST.ExprStmt({
            a = None;
            lnum = 6;
          });
      ];
      start_lnum = 3;
      end_lnum = 7;
    }
  } in
  assert_equal ast expected

let parse_fxn_list _test_ctxt =
  let code = "@VB\n sub foo()\n end sub\n @@\n sub main()\n end sub\n\n\n" in
  let ast = parse_string code in
  let expected = {
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
  assert_equal ast expected

let parse_stmt_list _test_ctxt =
  let code = "@VB\n @@\n sub main()\n if true then\n end if\n while (true)\n end while\n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.TrueExpr;
            lnum = 2;
          }, AST.BlockStmt [], 2);
        AST.WhileStmt({
            a = AST.TrueExpr;
            lnum = 4;
          }, AST.BlockStmt [], 4);
      ];
      start_lnum = 1;
      end_lnum = 6;
    }
  } in
  assert_equal ast expected

let parse_negative_int _test_ctxt =
  let code = "@VB\n @@\n sub main()\n foo(-1)\n end sub" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.ExprStmt({
            a = Some {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("foo");
                    lnum = 2;
                  }, [{
                    a = AST.IntExpr(-1);
                    lnum = 2;
                  }]);
                lnum = 2;
              };
            lnum = 2;
          })
      ];
      start_lnum = 1;
      end_lnum = 3;
    }
  } in
  assert_equal ast expected

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
  ]
