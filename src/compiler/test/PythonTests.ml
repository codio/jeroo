open OUnit2
open Lib
open AST

let parse_string s =
  let lexbuf = Lexing.from_string s in
  PythonParser.translation_unit (PythonLexer.token (PythonLexerState.create())) lexbuf

let parse_empty _test_ctxt =
  let code = "@PYTHON\n@@\n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [];
      start_lnum = 1;
      end_lnum = 2;
    };
  } in
  assert_equal ast expected

let parse_main _test_ctxt =
  let code = "@PYTHON\n @@\n True \n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.BlockStmt([
            AST.ExprStmt({
                a = Some {
                    a = AST.TrueExpr;
                    lnum = 1;
                  };
                lnum = 1;
              });
          ])
      ];
      start_lnum = 1;
      end_lnum = 2;
    };
  } in
  assert_equal expected ast

let parse_if _test_ctxt =
  let code = "@PYTHON\n@@\n if True: True\n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.TrueExpr;
            lnum = 1;
          }, AST.BlockStmt([
            AST.ExprStmt({
                a = Some {
                    a = TrueExpr;
                    lnum = 1;
                  };
                lnum = 1;
              })
          ]), 1)
      ];
      start_lnum = 1;
      end_lnum = 2;
    };
  } in
  assert_equal expected ast

let parse_if_else _test_ctxt =
  let code = "@PYTHON\n@@\nif True:\n\t True\nelse:\n\t False\n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfElseStmt(
          {
            a = AST.TrueExpr;
            lnum = 1;
          }, AST.BlockStmt([
              AST.BlockStmt [
                AST.ExprStmt({
                    a = Some {
                        a = TrueExpr;
                        lnum = 2;
                      };
                    lnum = 2;
                  })
              ]]),
        AST.BlockStmt([
            BlockStmt [
            AST.ExprStmt({
                a = Some {
                    a = FalseExpr;
                    lnum = 4;
                  };
                lnum = 4;
              })]]),
        1)
      ];
      start_lnum = 1;
      end_lnum = 5;
    };
  } in
  assert_equal expected ast

let parse_if_elif _test_ctxt =
  let code = "@PYTHON\n@@\nif True: True\nelif False: False\n" in
  let ast  = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfElseStmt({
            a = AST.TrueExpr;
            lnum = 1;
          }, AST.BlockStmt([
            AST.ExprStmt({
                a = Some {
                    a = TrueExpr;
                    lnum = 1;
                  };
                lnum = 1;
              })
          ]), AST.IfStmt({
            a = AST.FalseExpr;
            lnum = 2;
          }, AST.BlockStmt([
            AST.ExprStmt({
                a = Some {
                    a = FalseExpr;
                    lnum = 2;
                  };
                lnum = 2;
              })
          ]), 2), 1)
      ];
      start_lnum = 1;
      end_lnum = 3;
    };
  } in
  assert_equal expected ast

let parse_if_elif_else _test_ctxt =
  let code = "@PYTHON\n@@\nif True: True\nelif False: False\nelse: True\n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfElseStmt({
            a = AST.TrueExpr;
            lnum = 1;
          }, AST.BlockStmt([
            AST.ExprStmt({
                a = Some {
                    a = TrueExpr;
                    lnum = 1;
                  };
                lnum = 1;
              })
          ]), AST.IfElseStmt({
            a = AST.FalseExpr;
            lnum = 2;
          }, AST.BlockStmt([
            AST.ExprStmt({
                a = Some {
                    a = FalseExpr;
                    lnum = 2;
                  };
                lnum = 2;
              })
          ]), AST.BlockStmt([
            AST.ExprStmt({
                a = Some {
                    a = TrueExpr;
                    lnum = 3;
                  };
                lnum = 3;
              })
          ]), 2), 1)
      ];
      start_lnum = 1;
      end_lnum = 4;
    };
  } in
  assert_equal expected ast

let parse_nested_if _test_ctxt =
  let code = "@PYTHON\n@@\nif True:\n\tif False:\n\t\tFalse\nelse:\n\tTrue\n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfElseStmt({
            a = AST.TrueExpr;
            lnum = 1;
          }, AST.BlockStmt([
            AST.IfStmt({
                a = AST.FalseExpr;
                lnum = 2;
              }, AST.BlockStmt([
                AST.BlockStmt([
                    ExprStmt {
                      a = Some {
                          a = FalseExpr;
                          lnum = 3;
                        };
                      lnum = 3;
                    }
                  ])
              ]), 2)
          ]), AST.BlockStmt([
            AST.BlockStmt([
                AST.ExprStmt({
                    a = Some {
                        a = TrueExpr;
                        lnum = 5;
                      };
                    lnum = 5;
                  })
              ])
          ]), 1)
      ];
      start_lnum = 1;
      end_lnum = 6;
    };
  } in
  assert_equal expected ast

let parse_while _test_ctxt =
  let code = "@PYTHON\n@@\n while True: False\n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.WhileStmt({
            a = AST.TrueExpr;
            lnum = 1;
          }, AST.BlockStmt([
            AST.ExprStmt({
                a = Some {
                    a = FalseExpr;
                    lnum = 1;
                  };
                lnum = 1;
              })
          ]), 1)
      ];
      start_lnum = 1;
      end_lnum = 2;
    };
  } in
  assert_equal expected ast

let parse_and _test_ctxt =
  let code = "@PYTHON\n@@\n if True and False: False\n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = BinOpExpr({
                a = TrueExpr;
                lnum = 1;
              }, AST.And, {
                  a = FalseExpr;
                  lnum = 1;
                });
            lnum = 1;
          }, AST.BlockStmt([
            AST.ExprStmt({
                a = Some {
                    a = FalseExpr;
                    lnum = 1;
                  };
                lnum = 1;
              })
          ]), 1)
      ];
      start_lnum = 1;
      end_lnum = 2;
    };
  } in
  assert_equal expected ast

let parse_or _test_ctxt =
  let code = "@PYTHON\n@@\n if True or False: False\n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = BinOpExpr({
                a = TrueExpr;
                lnum = 1;
              }, AST.Or, {
                  a = FalseExpr;
                  lnum = 1;
                });
            lnum = 1;
          }, AST.BlockStmt([
            AST.ExprStmt({
                a = Some {
                    a = FalseExpr;
                    lnum = 1;
                  };
                lnum = 1;
              })
          ]), 1)
      ];
      start_lnum = 1;
      end_lnum = 2;
    };
  } in
  assert_equal expected ast

let parse_not _test_ctxt =
  let code = "@PYTHON\n@@\n if not True: False\n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = UnOpExpr(AST.Not, {
                a = TrueExpr;
                lnum = 1;
              });
            lnum = 1;
          }, AST.BlockStmt([
            AST.ExprStmt({
                a = Some {
                    a = FalseExpr;
                    lnum = 1;
                  };
                lnum = 1;
              })
          ]), 1)
      ];
      start_lnum = 1;
      end_lnum = 2;
    };
  } in
  assert_equal expected ast

let parse_comment _test_ctxt =
  let code = "@PYTHON\n@@\n#this is a comment###\n\n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [];
      start_lnum = 1;
      end_lnum = 2;
    };
  } in
  assert_equal ast expected

let parse_inline_comment _test_ctxt =
  let code = "@PYTHON\n @@\n True #This is a comment too \n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.BlockStmt([
            AST.ExprStmt({
                a = Some {
                    a = AST.TrueExpr;
                    lnum = 1;
                  };
                lnum = 1;
              });
          ])
      ];
      start_lnum = 1;
      end_lnum = 2;
    };
  } in
  assert_equal expected ast

let parse_newlines _test_ctxt =
  let code = "@PYTHON\n\n\n\n\n\n@@\n\n\n\n\nTrue\n\n\n\n\n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.BlockStmt([
            AST.ExprStmt({
                a = Some {
                    a = AST.TrueExpr;
                    lnum = 5;
                  };
                lnum = 5;
              });
          ])
      ];
      start_lnum = 1;
      end_lnum = 6;
    };
  } in
  assert_equal expected ast

let parse_def _test_ctxt =
  let code = "@PYTHON\ndef foo(self):\n\tself.hop()@@\n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [
      {
        id = "foo";
        stmts = [
          AST.BlockStmt([
              AST.ExprStmt({
                  a = Some {
                      a = FxnAppExpr({
                          a = IdExpr("hop");
                          lnum = 2;
                        }, []);
                      lnum = 2;
                    };
                  lnum = 2;
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
  assert_equal expected ast

let parse_fxn_application _test_ctxt =
  let code = "@PYTHON\n@@\nfoo(True, NORTH)\n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.BlockStmt([
            AST.ExprStmt({
                a = Some {
                    a = AST.FxnAppExpr({
                        a = IdExpr("foo");
                        lnum = 1;
                      }, [
                          {
                            a = TrueExpr;
                            lnum = 1;
                          };
                          {
                            a = NorthExpr;
                            lnum = 1;
                          }
                        ]);
                    lnum = 1;
                  };
                lnum = 1;
              });
          ])
      ];
      start_lnum = 1;
      end_lnum = 2;
    };
  } in
  assert_equal expected ast

let parse_paren_precedence _test_ctxt =
  let code = "@PYTHON\n@@\nif True and (True and True):True\n" in
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
                      a = AST.TrueExpr;
                      lnum = 1;
                    }, AST.And, {
                        a = AST.TrueExpr;
                        lnum = 1;
                      });
                  lnum = 1;
                });
            lnum = 1;
          }, AST.BlockStmt [
            AST.ExprStmt {
              a = Some {
                  a = TrueExpr;
                  lnum = 1;
                };
              lnum = 1;
            }
          ], 1)
      ];
      start_lnum = 1;
      end_lnum = 2;
    }
  } in
  assert_equal ast expected

let parse_and_or_precedence _test_ctxt =
  let code = "@PYTHON\n@@\nif True and True or True:True\n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.IfStmt({
            a = AST.BinOpExpr({
                a = BinOpExpr({
                    a = TrueExpr;
                    lnum = 1;
                  }, AST.And, {
                      a = TrueExpr;
                      lnum = 1;
                    });
                lnum = 1;
              }, AST.Or, {
                  a = TrueExpr;
                  lnum = 1;
                });
            lnum = 1;
          }, AST.BlockStmt [
            AST.ExprStmt {
              a = Some {
                  a = TrueExpr;
                  lnum = 1;
                };
              lnum = 1;
            }
          ], 1)
      ];
      start_lnum = 1;
      end_lnum = 2;
    }
  } in
  assert_equal ast expected

let parse_not_precedence _test_ctxt =
  let code = "@PYTHON\n@@\nif not True and True: True\n" in
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
                  a = AST.TrueExpr;
                  lnum = 1;
                });
            lnum = 1;
          }, AST.BlockStmt [
            AST.ExprStmt {
              a = Some {
                  a = TrueExpr;
                  lnum = 1;
                };
              lnum = 1;
            }
          ], 1)
      ];
      start_lnum = 1;
      end_lnum = 2;
    };
  } in
  assert_equal expected ast

let parse_object_member_access _test_ctxt =
  let code = "@PYTHON\n@@\na.b(1)\n" in
  let ast = parse_string code in
  let expected = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        BlockStmt [
          ExprStmt {
            a = Some {
                a = BinOpExpr({
                    a = IdExpr("a");
                    lnum = 1;
                  }, Dot, {
                      a = FxnAppExpr({
                          a = IdExpr("b");
                          lnum = 1;
                        }, [
                            {
                              a = IntExpr(1);
                              lnum = 1;
                            }
                          ]);
                      lnum = 1;
                    });
                lnum = 1;
              };
            lnum = 1;
          }
        ]
      ];
      start_lnum = 1;
      end_lnum = 2;
    };
  } in
  assert_equal ast expected

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
  ]
