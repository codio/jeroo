open OUnit2
open Lib
open AST

let codegen_jeroo_decl_no_args _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          })
      ];
      start_lnum = 1;
      end_lnum = 3;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.RETR (0, 3);
  ]

let codegen_jeroo_decl_set_x_y _test_ctxt =
  let ast = {
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
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 1, 2, 0, Bytecode.East, 2);
    Bytecode.RETR (0, 3);
  ]

let codegen_jeroo_decl_set_x_y_flowers _test_ctxt =
  let ast = {
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
                      {
                        a = AST.IntExpr(5);
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
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 1, 2, 5, Bytecode.East, 2);
    Bytecode.RETR (0, 3);
  ]

let codegen_jeroo_decl_set_x_y_flowers_direction _test_ctxt =
  let ast = {
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
                      {
                        a = AST.IntExpr(5);
                        lnum = 2;
                      };
                      {
                        a = AST.SouthExpr;
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
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 1, 2, 5, Bytecode.South, 2);
    Bytecode.RETR (0, 3);
  ]

let codegen_jeroo_decl_invalid_args _test_ctxt =
  let ast = {
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
                        a = AST.IntExpr(2);
                        lnum = 2;
                      };
                      {
                        a = AST.IntExpr(2);
                        lnum = 2;
                      };
                      {
                        a = AST.IntExpr(2);
                        lnum = 2;
                      };
                      {
                        a = AST.SouthExpr;
                        lnum = 2;
                      };
                      {
                        a = AST.IntExpr(2);
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
  assert_raises (Codegen.SemanticException {
      lnum = 2;
      message = "Invalid Jeroo arguments"
    }) (fun () -> Codegen.codegen ast)

let codegen_jeroo_decl_no_new _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.IntExpr(1);
            lnum = 2;
          })
      ];
      start_lnum = 1;
      end_lnum = 3;
    }
  } in
  assert_raises (Codegen.SemanticException {
      lnum = 2;
      message = "Invalid right hand side of assignment, must be a Jeroo constructor"
    }) (fun () -> Codegen.codegen ast)

let codegen_unknown_decl_type _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("jer", "j", {
            a = AST.IntExpr(1);
            lnum = 2;
          })
      ];
      start_lnum = 1;
      end_lnum = 3;
    }
  } in
  assert_raises (Codegen.SemanticException {
      lnum = 2;
      message = "Invalid type, Jeroo is the only valid type"
    }) (fun () -> Codegen.codegen ast)

let codegen_unknown_ctor _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("jer");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          })
      ];
      start_lnum = 1;
      end_lnum = 3;
    }
  } in
  assert_raises (Codegen.SemanticException {
      lnum = 2;
      message = "Invalid constructor: jer, Jeroo is the only valid constructor"
    }) (fun () -> Codegen.codegen ast)

let codegen_duplicate_jeroo _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 3;
                  }, []);
                lnum = 3;
              });
            lnum = 3;
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  assert_raises (Codegen.SemanticException {
      lnum = 3;
      message = "Duplicate Jeroo declaration, j already defined"
    }) (fun () -> Codegen.codegen ast)

let codegen_jeroo_hop _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.ExprStmt({
            a = Some({
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 3;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("hop");
                          lnum = 3;
                        }, [
                            {
                              a = AST.IntExpr(2);
                              lnum = 3;
                            }
                          ]);
                      lnum = 3;
                    });
                lnum = 3;
              });
            lnum = 3
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, 0, 3);
    Bytecode.HOP (2, 0, 3);
    Bytecode.RETR (0, 4)
  ]

let codegen_multiple_jeroos_csr _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j1", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.DeclStmt("Jeroo", "j2", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 3;
                  }, [
                      {
                        a = AST.IntExpr(2);
                        lnum = 3;
                      };
                      {
                        a = AST.IntExpr(2);
                        lnum = 3;
                      }
                    ]);
                lnum = 3;
              });
            lnum = 3;
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j1");
                    lnum = 4;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("hop");
                          lnum = 4;
                        }, []);
                      lnum = 4;
                    });
                lnum = 4;
              };
            lnum = 4;
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j2");
                    lnum = 5;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("hop");
                          lnum = 5;
                        }, []);
                      lnum = 5;
                    });
                lnum = 5;
              };
            lnum = 5;
          })
      ];
      start_lnum = 1;
      end_lnum = 6;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.NEW (1, 2, 2, 0, Bytecode.East, 3);
    Bytecode.CSR (0, 0, 4);
    Bytecode.HOP (1, 0, 4);
    Bytecode.CSR (1, 0, 5);
    Bytecode.HOP (1, 0, 5);
    Bytecode.RETR (0, 6)
  ]

let codegen_pick_flower _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 3;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("pick");
                          lnum = 3;
                        }, []);
                      lnum = 3;
                    });
                lnum = 3;
              };
            lnum = 3;
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, 0, 3);
    Bytecode.PICK (0, 3);
    Bytecode.RETR (0, 4);
  ]

let codegen_plant_flower _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 3;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("plant");
                          lnum = 3;
                        }, []);
                      lnum = 3;
                    });
                lnum = 3;
              };
            lnum = 3;
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, 0, 3);
    Bytecode.PLANT (0, 3);
    Bytecode.RETR (0, 4);
  ]

let codegen_toss_flower _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 3;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("toss");
                          lnum = 3;
                        }, []);
                      lnum = 3;
                    });
                lnum = 3;
              };
            lnum = 3;
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, 0, 3);
    Bytecode.TOSS (0, 3);
    Bytecode.RETR (0, 4);
  ]

let codegen_give_default_args _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 3;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("give");
                          lnum = 3;
                        }, []);
                      lnum = 3;
                    });
                lnum = 3;
              };
            lnum = 3;
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, 0, 3);
    Bytecode.GIVE (Bytecode.Ahead, 0, 3);
    Bytecode.RETR (0, 4);
  ]

let codegen_give_in_direction _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 3;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("give");
                          lnum = 3;
                        }, [{
                          a = AST.LeftExpr;
                          lnum = 3;
                        }]);
                      lnum = 3;
                    });
                lnum = 3;
              };
            lnum = 3;
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, 0, 3);
    Bytecode.GIVE (Bytecode.Left, 0, 3);
    Bytecode.RETR (0, 4);
  ]

let codegen_turn _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 3;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("turn");
                          lnum = 3;
                        }, [{
                          a = AST.RightExpr;
                          lnum = 3;
                        }]);
                      lnum = 3;
                    });
                lnum = 3;
              };
            lnum = 3;
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, 0, 3);
    Bytecode.TURN (Bytecode.Right, 0, 3);
    Bytecode.RETR (0, 4);
  ]

let codegen_has_flower _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 3;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("hasFlower");
                          lnum = 3;
                        }, []);
                      lnum = 3;
                    });
                lnum = 3;
              };
            lnum = 3;
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, 0, 3);
    Bytecode.HASFLWR (0, 3);
    Bytecode.RETR (0, 4);
  ]

let codegen_is_jeroo _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 3;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("isJeroo");
                          lnum = 3;
                        }, [{
                          a = AST.AheadExpr;
                          lnum = 3;
                        }]);
                      lnum = 3;
                    });
                lnum = 3;
              };
            lnum = 3;
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, 0, 3);
    Bytecode.ISJEROO (Bytecode.Ahead, 0, 3);
    Bytecode.RETR (0, 4);
  ]

let codegen_is_facing _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 3;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("isFacing");
                          lnum = 3;
                        }, [{
                          a = AST.SouthExpr;
                          lnum = 3;
                        }]);
                      lnum = 3;
                    });
                lnum = 3;
              };
            lnum = 3;
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, 0, 3);
    Bytecode.FACING (Bytecode.South, 0, 3);
    Bytecode.RETR (0, 4);
  ]

let codegen_is_flower _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 3;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("isFlower");
                          lnum = 3;
                        }, [{
                          a = AST.AheadExpr;
                          lnum = 3;
                        }]);
                      lnum = 3;
                    });
                lnum = 3;
              };
            lnum = 3;
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, 0, 3);
    Bytecode.ISFLWR (Bytecode.Ahead, 0, 3);
    Bytecode.RETR (0, 4);
  ]

let codegen_is_net _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 3;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("isNet");
                          lnum = 3;
                        }, [{
                          a = AST.LeftExpr;
                          lnum = 3;
                        }]);
                      lnum = 3;
                    });
                lnum = 3;
              };
            lnum = 3;
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, 0, 3);
    Bytecode.ISNET (Bytecode.Left, 0, 3);
    Bytecode.RETR (0, 4);
  ]

let codegen_is_water _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 3;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("isWater");
                          lnum = 3;
                        }, [{
                          a = AST.RightExpr;
                          lnum = 3;
                        }]);
                      lnum = 3;
                    });
                lnum = 3;
              };
            lnum = 3;
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, 0, 3);
    Bytecode.ISWATER (Bytecode.Right, 0, 3);
    Bytecode.RETR (0, 4);
  ]

let codegen_call_custom_fxn _test_ctxt =
  let ast = {
    extension_fxns = [
      {
        id = "foo";
        stmts = [
          AST.ExprStmt({
              a = Some {
                  a = AST.FxnAppExpr({
                      a = AST.IdExpr("hop");
                      lnum = 2;
                    }, []);
                  lnum = 2;
                };
              lnum = 2;
            })
        ];
        start_lnum = 1;
        end_lnum = 3;
      }
    ];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.ExprStmt({
            a = Some({
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 3;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("foo");
                          lnum = 3;
                        }, []);
                      lnum = 3;
                    });
                lnum = 3;
              });
            lnum = 3;
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (3, 0, 1);
    Bytecode.HOP (1, 1, 2);
    Bytecode.RETR (1, 3);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, 0, 3);
    Bytecode.CALLBK (0, 3);
    Bytecode.JUMP (1, 0, 3);
    Bytecode.RETR (0, 4)
  ]

let codegen_call_missing_fxn _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 3;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("foo");
                          lnum = 3;
                        }, []);
                      lnum = 3;
                    });
                lnum = 3;
              };
            lnum = 3;
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  assert_raises (Codegen.SemanticException {
      lnum = 3;
      message = "Unknown function: foo"
    }) (fun () -> Codegen.codegen ast)

let codegen_if_stmt _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.IfStmt({
            a = AST.TrueExpr;
            lnum = 3;
          }, AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 4;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("hop");
                          lnum = 4;
                        }, []);
                      lnum = 4;
                    });
                lnum = 4;
              };
            lnum = 4;
          }), 3);
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 5;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("turn");
                          lnum = 5;
                        }, [{
                          a = AST.RightExpr;
                          lnum = 5;
                        }]);
                      lnum = 5;
                    });
                lnum = 5;
              };
            lnum = 5;
          })
      ];
      start_lnum = 1;
      end_lnum = 6;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.TRUE (0, 3);
    Bytecode.BZ (6, 0, 3);
    Bytecode.CSR (0, 0, 4);
    Bytecode.HOP (1, 0, 4);
    Bytecode.CSR (0, 0, 5);
    Bytecode.TURN (Bytecode.Right, 0, 5);
    Bytecode.RETR (0, 6);
  ]

let codegen_if_else _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.IfElseStmt({
            a = AST.TrueExpr;
            lnum = 3;
          }, AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 4;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("hop");
                          lnum = 4;
                        }, []);
                      lnum = 4;
                    });
                lnum = 4;
              };
            lnum = 4;
          }), AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 6;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("turn");
                          lnum = 6;
                        }, [{
                          a = AST.LeftExpr;
                          lnum = 6;
                        }]);
                      lnum = 6;
                    });
                lnum = 6;
              };
            lnum = 6;
          }), 3);
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 7;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("turn");
                          lnum = 7;
                        }, [{
                          a = AST.RightExpr;
                          lnum = 7;
                        }]);
                      lnum = 7;
                    });
                lnum = 7;
              };
            lnum = 7;
          })
      ];
      start_lnum = 1;
      end_lnum = 8;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.TRUE (0, 3);
    Bytecode.BZ (7, 0, 3);
    Bytecode.CSR (0, 0, 4);
    Bytecode.HOP (1, 0, 4);
    Bytecode.JUMP (9, 0, 4);
    Bytecode.CSR (0, 0, 6);
    Bytecode.TURN (Bytecode.Left, 0, 6);
    Bytecode.CSR (0, 0, 7);
    Bytecode.TURN (Bytecode.Right, 0, 7);
    Bytecode.RETR (0 ,8);
  ]

let codegen_while _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    lnum = 2;
                  }, []);
                lnum = 2;
              });
            lnum = 2;
          });
        AST.WhileStmt({
            a = AST.TrueExpr;
            lnum = 3;
          }, AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 4;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("hop");
                          lnum = 4;
                        }, []);
                      lnum = 4;
                    });
                lnum = 4;
              };
            lnum = 4;
          }), 3);
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 5;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("turn");
                          lnum = 5;
                        }, [{
                          a = AST.LeftExpr;
                          lnum = 5;
                        }]);
                      lnum = 5;
                    });
                lnum = 5;
              };
            lnum = 5;
          })
      ];
      start_lnum = 1;
      end_lnum = 6;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal bytecode [
    Bytecode.JUMP (1, 0, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.TRUE (0, 3);
    Bytecode.BZ (7, 0, 3);
    Bytecode.CSR (0, 0, 4);
    Bytecode.HOP (1, 0, 4);
    Bytecode.JUMP (2, 0, 4);
    Bytecode.CSR (0, 0, 5);
    Bytecode.TURN (Bytecode.Left, 0, 5);
    Bytecode.RETR (0, 6);
  ]

let codegen_unknown_fxn _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        ExprStmt({
            a = Some {
                a = FxnAppExpr({
                    a = IdExpr("foo");
                    lnum = 1;
                  }, []);
                lnum = 1;
              };
            lnum = 1;
          })
      ];
      start_lnum = 1;
      end_lnum = 3;
    }
  } in
  assert_raises (Codegen.SemanticException {
      lnum = 1;
      message = "Unknown function: foo"
    }) (fun () -> Codegen.codegen ast)

let codegen_duplicate_fxn _test_ctxt =
  let ast = {
    extension_fxns = [{
        id = "main";
        stmts = [];
        start_lnum = 1;
        end_lnum = 2;
      }];
    main_fxn = {
      id = "main";
      stmts = [];
      start_lnum = 1;
      end_lnum = 2;
    }
  } in
  assert_raises (Codegen.SemanticException {
      lnum = 1;
      message = "duplicate function declaration, main already defined"
    }) (fun () -> Codegen.codegen ast)

let codegen_unknown_jeroo _test_ctxt =
  let ast = {
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.ExprStmt({
            a = Some({
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    lnum = 3;
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("foo");
                          lnum = 3;
                        }, []);
                      lnum = 3;
                    });
                lnum = 3;
              });
            lnum = 3;
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  assert_raises (Codegen.SemanticException {
      lnum = 3;
      message = "Unknown Jeroo: j"
    }) (fun () -> Codegen.codegen ast)

let suite =
  "Codegen">::: [
    "Generate jeroo decl with default args">:: codegen_jeroo_decl_no_args;
    "Generate jeroo decl with custom x and y">:: codegen_jeroo_decl_set_x_y;
    "Generate jeroo decl with custom x, y, and flowers">:: codegen_jeroo_decl_set_x_y_flowers;
    "Generate jeroo decl with custom x, y, flowers, and direction">:: codegen_jeroo_decl_set_x_y_flowers_direction;
    "Generate jeroo decl invalid args throws exception">:: codegen_jeroo_decl_invalid_args;
    "Generate jeroo decl no new expr">:: codegen_jeroo_decl_no_new;
    "Generate unknown type throws exception">:: codegen_unknown_decl_type;
    "Generate unknown constructor throws exception">:: codegen_unknown_ctor;
    "Generate duplicate jeroo throws exception">::codegen_duplicate_jeroo;
    "Generate Jeroo hop">:: codegen_jeroo_hop;
    "Generate CSR for multiple Jeroos">:: codegen_multiple_jeroos_csr;
    "Generate pick instruction">:: codegen_pick_flower;
    "Generate plant instruction">:: codegen_plant_flower;
    "Generate toss instruction">:: codegen_toss_flower;
    "Generate give default args">:: codegen_give_default_args;
    "Generate give in a direction">:: codegen_give_in_direction;
    "Generate turn instruction">:: codegen_turn;
    "Generate hasFlower">:: codegen_has_flower;
    "Generate isJeroo">:: codegen_is_jeroo;
    "Generate isFacing">:: codegen_is_facing;
    "Generate isFlower">:: codegen_is_flower;
    "Generate isNet">:: codegen_is_net;
    "Generate isWater">:: codegen_is_water;
    "Generate calling custom methods">:: codegen_call_custom_fxn;
    "Calling missing function generates error">:: codegen_call_missing_fxn;
    "Generate if statement">:: codegen_if_stmt;
    "Generate if-else statement">:: codegen_if_else;
    "Generate while statement">:: codegen_while;
    "Generate unknown function throws exception">:: codegen_unknown_fxn;
    "Generate duplicate function throws exception">:: codegen_duplicate_fxn;
    "Generate unknown jeroo throws exception">:: codegen_unknown_jeroo;
  ]
