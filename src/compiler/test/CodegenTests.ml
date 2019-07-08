open OUnit2
open Lib
open AST

let create_expected_tbl () = Hashtbl.create 10

let codegen_jeroo_decl_no_args _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 3;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in
  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.RETR (Pane.Main, 3);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_jeroo_decl_set_x_y _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, [
                      {
                        a = AST.IntExpr(1);
                        pos = { lnum = 2; cnum = 0; };
                      };
                      {
                        a = AST.IntExpr(2);
                        pos = { lnum = 2; cnum = 0; };
                      }
                    ]);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 3;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 1, 2, 0, Bytecode.East, 2);
    Bytecode.RETR (Pane.Main, 3);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_jeroo_decl_set_x_y_flowers _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, [
                      {
                        a = AST.IntExpr(1);
                        pos = { lnum = 2; cnum = 0; };
                      };
                      {
                        a = AST.IntExpr(2);
                        pos = { lnum = 2; cnum = 0; };
                      };
                      {
                        a = AST.IntExpr(5);
                        pos = { lnum = 2; cnum = 0; };
                      }
                    ]);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 3;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;


  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 1, 2, 5, Bytecode.East, 2);
    Bytecode.RETR (Pane.Main, 3);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_jeroo_decl_set_x_y_flowers_direction _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, [
                      {
                        a = AST.IntExpr(1);
                        pos = { lnum = 2; cnum = 0; };
                      };
                      {
                        a = AST.IntExpr(2);
                        pos = { lnum = 2; cnum = 0; };
                      };
                      {
                        a = AST.IntExpr(5);
                        pos = { lnum = 2; cnum = 0; };
                      };
                      {
                        a = AST.SouthExpr;
                        pos = { lnum = 2; cnum = 0; };
                      }
                    ]);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 3;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 1, 2, 5, Bytecode.South, 2);
    Bytecode.RETR (Pane.Main, 3);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_jeroo_hop _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.ExprStmt({
            a = Some({
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 3; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("hop");
                          pos = { lnum = 3; cnum = 0; };
                        }, [
                            {
                              a = AST.IntExpr(2);
                              pos = { lnum = 3; cnum = 0; };
                            }
                          ]);
                      pos = { lnum = 3; cnum = 0; };
                    });
                pos = { lnum = 3; cnum = 0; };
              });
            pos = { lnum = 3; cnum = 0; }
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, Pane.Main, 3);
    Bytecode.HOP (2, Pane.Main, 3);
    Bytecode.RETR (Pane.Main, 4)
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_multiple_jeroos_csr _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j1", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.DeclStmt("Jeroo", "j2", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 3; cnum = 0; };
                  }, [
                      {
                        a = AST.IntExpr(2);
                        pos = { lnum = 3; cnum = 0; };
                      };
                      {
                        a = AST.IntExpr(2);
                        pos = { lnum = 3; cnum = 0; };
                      }
                    ]);
                pos = { lnum = 3; cnum = 0; };
              });
            pos = { lnum = 3; cnum = 0; };
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j1");
                    pos = { lnum = 4; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("hop");
                          pos = { lnum = 4; cnum = 0; };
                        }, []);
                      pos = { lnum = 4; cnum = 0; };
                    });
                pos = { lnum = 4; cnum = 0; };
              };
            pos = { lnum = 4; cnum = 0; };
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j2");
                    pos = { lnum = 5; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("hop");
                          pos = { lnum = 5; cnum = 0; };
                        }, []);
                      pos = { lnum = 5; cnum = 0; };
                    });
                pos = { lnum = 5; cnum = 0; };
              };
            pos = { lnum = 5; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 6;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j1" 0;
  Hashtbl.add expected_tbl "j2" 1;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.NEW (1, 2, 2, 0, Bytecode.East, 3);
    Bytecode.CSR (0, Pane.Main, 4);
    Bytecode.HOP (1, Pane.Main, 4);
    Bytecode.CSR (1, Pane.Main, 5);
    Bytecode.HOP (1, Pane.Main, 5);
    Bytecode.RETR (Pane.Main, 6)
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_pick_flower _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 3; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("pick");
                          pos = { lnum = 3; cnum = 0; };
                        }, []);
                      pos = { lnum = 3; cnum = 0; };
                    });
                pos = { lnum = 3; cnum = 0; };
              };
            pos = { lnum = 3; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, Pane.Main, 3);
    Bytecode.PICK (Pane.Main, 3);
    Bytecode.RETR (Pane.Main, 4);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_plant_flower _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 3; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("plant");
                          pos = { lnum = 3; cnum = 0; };
                        }, []);
                      pos = { lnum = 3; cnum = 0; };
                    });
                pos = { lnum = 3; cnum = 0; };
              };
            pos = { lnum = 3; cnum = 0; };
          })
    ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, Pane.Main, 3);
    Bytecode.PLANT (Pane.Main, 3);
    Bytecode.RETR (Pane.Main, 4);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_toss_flower _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 3; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("toss");
                          pos = { lnum = 3; cnum = 0; };
                        }, []);
                      pos = { lnum = 3; cnum = 0; };
                    });
                pos = { lnum = 3; cnum = 0; };
              };
            pos = { lnum = 3; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, Pane.Main, 3);
    Bytecode.TOSS (Pane.Main, 3);
    Bytecode.RETR (Pane.Main, 4);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_give_default_args _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 3; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("give");
                          pos = { lnum = 3; cnum = 0; };
                        }, []);
                      pos = { lnum = 3; cnum = 0; };
                    });
                pos = { lnum = 3; cnum = 0; };
              };
            pos = { lnum = 3; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, Pane.Main, 3);
    Bytecode.GIVE (Bytecode.Ahead, Pane.Main, 3);
    Bytecode.RETR (Pane.Main, 4);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_give_in_direction _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 3; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("give");
                          pos = { lnum = 3; cnum = 0; };
                        }, [{
                          a = AST.LeftExpr;
                          pos = { lnum = 3; cnum = 0; };
                        }]);
                      pos = { lnum = 3; cnum = 0; };
                    });
                pos = { lnum = 3; cnum = 0; };
              };
            pos = { lnum = 3; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, Pane.Main, 3);
    Bytecode.GIVE (Bytecode.Left, Pane.Main, 3);
    Bytecode.RETR (Pane.Main, 4);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_turn _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 3; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("turn");
                          pos = { lnum = 3; cnum = 0; };
                        }, [{
                          a = AST.RightExpr;
                          pos = { lnum = 3; cnum = 0; };
                        }]);
                      pos = { lnum = 3; cnum = 0; };
                    });
                pos = { lnum = 3; cnum = 0; };
              };
            pos = { lnum = 3; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, Pane.Main, 3);
    Bytecode.TURN (Bytecode.Right, Pane.Main, 3);
    Bytecode.RETR (Pane.Main, 4);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_has_flower _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 3; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("hasFlower");
                          pos = { lnum = 3; cnum = 0; };
                        }, []);
                      pos = { lnum = 3; cnum = 0; };
                    });
                pos = { lnum = 3; cnum = 0; };
              };
            pos = { lnum = 3; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, Pane.Main, 3);
    Bytecode.HASFLWR (Pane.Main, 3);
    Bytecode.RETR (Pane.Main, 4);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_is_jeroo _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 3; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("isJeroo");
                          pos = { lnum = 3; cnum = 0; };
                        }, [{
                          a = AST.AheadExpr;
                          pos = { lnum = 3; cnum = 0; };
                        }]);
                      pos = { lnum = 3; cnum = 0; };
                    });
                pos = { lnum = 3; cnum = 0; };
              };
            pos = { lnum = 3; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, Pane.Main, 3);
    Bytecode.ISJEROO (Bytecode.Ahead, Pane.Main, 3);
    Bytecode.RETR (Pane.Main, 4);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_is_facing _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 3; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("isFacing");
                          pos = { lnum = 3; cnum = 0; };
                        }, [{
                          a = AST.SouthExpr;
                          pos = { lnum = 3; cnum = 0; };
                        }]);
                      pos = { lnum = 3; cnum = 0; };
                    });
                pos = { lnum = 3; cnum = 0; };
              };
            pos = { lnum = 3; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, Pane.Main, 3);
    Bytecode.FACING (Bytecode.South, Pane.Main, 3);
    Bytecode.RETR (Pane.Main, 4);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_is_flower _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 3; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("isFlower");
                          pos = { lnum = 3; cnum = 0; };
                        }, [{
                          a = AST.AheadExpr;
                          pos = { lnum = 3; cnum = 0; };
                        }]);
                      pos = { lnum = 3; cnum = 0; };
                    });
                pos = { lnum = 3; cnum = 0; };
              };
            pos = { lnum = 3; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, Pane.Main, 3);
    Bytecode.ISFLWR (Bytecode.Ahead, Pane.Main, 3);
    Bytecode.RETR (Pane.Main, 4);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_is_net _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 3; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("isNet");
                          pos = { lnum = 3; cnum = 0; };
                        }, [{
                          a = AST.LeftExpr;
                          pos = { lnum = 3; cnum = 0; };
                        }]);
                      pos = { lnum = 3; cnum = 0; };
                    });
                pos = { lnum = 3; cnum = 0; };
              };
            pos = { lnum = 3; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, Pane.Main, 3);
    Bytecode.ISNET (Bytecode.Left, Pane.Main, 3);
    Bytecode.RETR (Pane.Main, 4);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_is_water _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 3; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("isWater");
                          pos = { lnum = 3; cnum = 0; };
                        }, [{
                          a = AST.RightExpr;
                          pos = { lnum = 3; cnum = 0; };
                        }]);
                      pos = { lnum = 3; cnum = 0; };
                    });
                pos = { lnum = 3; cnum = 0; };
              };
            pos = { lnum = 3; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode = List.of_seq (fst (Codegen.codegen ast)) in
  assert_equal ~printer:[%show: Bytecode.bytecode list] bytecode [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, Pane.Main, 3);
    Bytecode.ISWATER (Bytecode.Right, Pane.Main, 3);
    Bytecode.RETR (Pane.Main, 4);
  ]
let codegen_call_custom_fxn _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [
      {
        id = "foo";
        stmts = [
          AST.ExprStmt({
              a = Some {
                  a = AST.FxnAppExpr({
                      a = AST.IdExpr("hop");
                      pos = { lnum = 2; cnum = 0; };
                    }, []);
                  pos = { lnum = 2; cnum = 0; };
                };
              pos = { lnum = 2; cnum = 0; };
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
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.ExprStmt({
            a = Some({
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 3; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("foo");
                          pos = { lnum = 3; cnum = 0; };
                        }, []);
                      pos = { lnum = 3; cnum = 0; };
                    });
                pos = { lnum = 3; cnum = 0; };
              });
            pos = { lnum = 3; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 4;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (3, Pane.Main, 1);
    Bytecode.HOP (1, Pane.Extensions, 2);
    Bytecode.RETR (Pane.Extensions, 3);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.CSR (0, Pane.Main, 3);
    Bytecode.CALLBK (Pane.Main, 3);
    Bytecode.JUMP (1, Pane.Main, 3);
    Bytecode.RETR (Pane.Main, 4)
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_if_stmt _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.IfStmt {
          a = ({
              a = AST.TrueExpr;
              pos = { lnum = 3; cnum = 0; };
            }, AST.ExprStmt({
              a = Some {
                  a = AST.BinOpExpr({
                      a = AST.IdExpr("j");
                      pos = { lnum = 4; cnum = 0; };
                    }, AST.Dot, {
                        a = AST.FxnAppExpr({
                            a = AST.IdExpr("hop");
                            pos = { lnum = 4; cnum = 0; };
                          }, []);
                        pos = { lnum = 4; cnum = 0; };
                      });
                  pos = { lnum = 4; cnum = 0; };
                };
              pos = { lnum = 4; cnum = 0; };
            }));
          pos = { lnum = 3; cnum = 0; };
        };
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 5; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("turn");
                          pos = { lnum = 5; cnum = 0; };
                        }, [{
                          a = AST.RightExpr;
                          pos = { lnum = 5; cnum = 0; };
                        }]);
                      pos = { lnum = 5; cnum = 0; };
                    });
                pos = { lnum = 5; cnum = 0; };
              };
            pos = { lnum = 5; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 6;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.TRUE (Pane.Main, 3);
    Bytecode.BZ (6, Pane.Main, 3);
    Bytecode.CSR (0, Pane.Main, 4);
    Bytecode.HOP (1, Pane.Main, 4);
    Bytecode.CSR (0, Pane.Main, 5);
    Bytecode.TURN (Bytecode.Right, Pane.Main, 5);
    Bytecode.RETR (Pane.Main, 6);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_if_else _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.IfElseStmt{
          a = ({
              a = AST.TrueExpr;
              pos = { lnum = 3; cnum = 0; };
            }, AST.ExprStmt({
              a = Some {
                  a = AST.BinOpExpr({
                      a = AST.IdExpr("j");
                      pos = { lnum = 4; cnum = 0; };
                    }, AST.Dot, {
                        a = AST.FxnAppExpr({
                            a = AST.IdExpr("hop");
                            pos = { lnum = 4; cnum = 0; };
                          }, []);
                        pos = { lnum = 4; cnum = 0; };
                      });
                  pos = { lnum = 4; cnum = 0; };
                };
              pos = { lnum = 4; cnum = 0; };
            }), AST.ExprStmt({
              a = Some {
                  a = AST.BinOpExpr({
                      a = AST.IdExpr("j");
                      pos = { lnum = 6; cnum = 0; };
                    }, AST.Dot, {
                        a = AST.FxnAppExpr({
                            a = AST.IdExpr("turn");
                            pos = { lnum = 6; cnum = 0; };
                          }, [{
                            a = AST.LeftExpr;
                            pos = { lnum = 6; cnum = 0; };
                          }]);
                        pos = { lnum = 6; cnum = 0; };
                      });
                  pos = { lnum = 6; cnum = 0; };
                };
              pos = { lnum = 6; cnum = 0; };
            }));
              pos = { lnum = 3; cnum = 0; };
        };
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 7; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("turn");
                          pos = { lnum = 7; cnum = 0; };
                        }, [{
                          a = AST.RightExpr;
                          pos = { lnum = 7; cnum = 0; };
                        }]);
                      pos = { lnum = 7; cnum = 0; };
                    });
                pos = { lnum = 7; cnum = 0; };
              };
            pos = { lnum = 7; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 8;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.TRUE (Pane.Main, 3);
    Bytecode.BZ (7, Pane.Main, 3);
    Bytecode.CSR (0, Pane.Main, 4);
    Bytecode.HOP (1, Pane.Main, 4);
    Bytecode.JUMP (9, Pane.Main, 4);
    Bytecode.CSR (0, Pane.Main, 6);
    Bytecode.TURN (Bytecode.Left, Pane.Main, 6);
    Bytecode.CSR (0, Pane.Main, 7);
    Bytecode.TURN (Bytecode.Right, Pane.Main, 7);
    Bytecode.RETR (Pane.Main, 8);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let codegen_while _test_ctxt =
  let ast = { language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      id = "main";
      stmts = [
        AST.DeclStmt("Jeroo", "j", {
            a = AST.UnOpExpr(AST.New, {
                a = AST.FxnAppExpr({
                    a = AST.IdExpr("Jeroo");
                    pos = { lnum = 2; cnum = 0; };
                  }, []);
                pos = { lnum = 2; cnum = 0; };
              });
            pos = { lnum = 2; cnum = 0; };
          });
        AST.WhileStmt {
          a = ({
              a = AST.TrueExpr;
              pos = { lnum = 3; cnum = 0; };
            }, AST.ExprStmt({
              a = Some {
                  a = AST.BinOpExpr({
                      a = AST.IdExpr("j");
                      pos = { lnum = 4; cnum = 0; };
                    }, AST.Dot, {
                        a = AST.FxnAppExpr({
                            a = AST.IdExpr("hop");
                            pos = { lnum = 4; cnum = 0; };
                          }, []);
                        pos = { lnum = 4; cnum = 0; };
                      });
                  pos = { lnum = 4; cnum = 0; };
                };
              pos = { lnum = 4; cnum = 0; };
            }));
          pos = { lnum = 3; cnum = 0; }
        };
        AST.ExprStmt({
            a = Some {
                a = AST.BinOpExpr({
                    a = AST.IdExpr("j");
                    pos = { lnum = 5; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.FxnAppExpr({
                          a = AST.IdExpr("turn");
                          pos = { lnum = 5; cnum = 0; };
                        }, [{
                          a = AST.LeftExpr;
                          pos = { lnum = 5; cnum = 0; };
                        }]);
                      pos = { lnum = 5; cnum = 0; };
                    });
                pos = { lnum = 5; cnum = 0; };
              };
            pos = { lnum = 5; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 6;
    }
  } in
  let bytecode, jeroo_tbl = Codegen.codegen ast in

  let expected_tbl = create_expected_tbl () in
  Hashtbl.add expected_tbl "j" 0;

  assert_equal ~printer:[%show: Bytecode.bytecode list] [
    Bytecode.JUMP (1, Pane.Main, 1);
    Bytecode.NEW (0, 0, 0, 0, Bytecode.East, 2);
    Bytecode.TRUE (Pane.Main, 3);
    Bytecode.BZ (7, Pane.Main, 3);
    Bytecode.CSR (0, Pane.Main, 4);
    Bytecode.HOP (1, Pane.Main, 4);
    Bytecode.JUMP (2, Pane.Main, 4);
    Bytecode.CSR (0, Pane.Main, 5);
    Bytecode.TURN (Bytecode.Left, Pane.Main, 5);
    Bytecode.RETR (Pane.Main, 6);
  ] (List.of_seq bytecode);

  assert_equal expected_tbl jeroo_tbl

let suite =
  "Codegen">::: [
    "Generate jeroo decl with default args">:: codegen_jeroo_decl_no_args;
    "Generate jeroo decl with custom x and y">:: codegen_jeroo_decl_set_x_y;
    "Generate jeroo decl with custom x, y, and flowers">:: codegen_jeroo_decl_set_x_y_flowers;
    "Generate jeroo decl with custom x, y, flowers, and direction">:: codegen_jeroo_decl_set_x_y_flowers_direction;
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
    "Generate if statement">:: codegen_if_stmt;
    "Generate if-else statement">:: codegen_if_else;
    "Generate while statement">:: codegen_while;
  ]
