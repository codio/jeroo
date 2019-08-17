open OUnit2
open Lib
open AST

let typecheck_decl_no_args _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
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
                ];
                start_lnum = 1;
                end_lnum = 3;
              }
            }
  in
  TypeChecker.typecheck ast

let typecheck_decl_flowers _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.DeclStmt("Jeroo", "j", {
                      a = AST.UnOpExpr(AST.New, {
                          a = AST.FxnAppExpr({
                              a = AST.IdExpr("Jeroo");
                              pos = { lnum = 2; cnum = 0; };
                            }, [
                                { a = AST.IntExpr 1; pos = { lnum = 2; cnum = 0; } }
                              ]
                            );
                          pos = { lnum = 2; cnum = 0; };
                        });
                      pos = { lnum = 2; cnum = 0; };
                    });
                ];
                start_lnum = 1;
                end_lnum = 3;
              }
            }
  in
  TypeChecker.typecheck ast

let typecheck_decl_x_y _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.DeclStmt("Jeroo", "j", {
                      a = AST.UnOpExpr(AST.New, {
                          a = AST.FxnAppExpr({
                              a = AST.IdExpr("Jeroo");
                              pos = { lnum = 2; cnum = 0; };
                            }, [
                                { a = AST.IntExpr 1; pos = { lnum = 2; cnum = 0; } };
                                { a = AST.IntExpr 1; pos = { lnum = 2; cnum = 0; } }
                              ]
                            );
                          pos = { lnum = 2; cnum = 0; };
                        });
                      pos = { lnum = 2; cnum = 0; };
                    });
                ];
                start_lnum = 1;
                end_lnum = 3;
              }
            }
  in
  TypeChecker.typecheck ast

let typecheck_decl_x_y_flowers _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.DeclStmt("Jeroo", "j", {
                      a = AST.UnOpExpr(AST.New, {
                          a = AST.FxnAppExpr({
                              a = AST.IdExpr("Jeroo");
                              pos = { lnum = 2; cnum = 0; };
                            }, [
                                { a = AST.IntExpr 1; pos = { lnum = 2; cnum = 0; } };
                                { a = AST.IntExpr 1; pos = { lnum = 2; cnum = 0; } };
                                { a = AST.IntExpr 1; pos = { lnum = 2; cnum = 0; } }
                              ]
                            );
                          pos = { lnum = 2; cnum = 0; };
                        });
                      pos = { lnum = 2; cnum = 0; };
                    });
                ];
                start_lnum = 1;
                end_lnum = 3;
              }
            }
  in
  TypeChecker.typecheck ast

let typecheck_decl_x_y_direction _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.DeclStmt("Jeroo", "j", {
                      a = AST.UnOpExpr(AST.New, {
                          a = AST.FxnAppExpr({
                              a = AST.IdExpr("Jeroo");
                              pos = { lnum = 2; cnum = 0; };
                            }, [
                                { a = AST.IntExpr 1; pos = { lnum = 2; cnum = 0; } };
                                { a = AST.IntExpr 1; pos = { lnum = 2; cnum = 0; } };
                                { a = AST.SouthExpr; pos = { lnum = 2; cnum = 0; } }
                              ]
                            );
                          pos = { lnum = 2; cnum = 0; };
                        });
                      pos = { lnum = 2; cnum = 0; };
                    });
                ];
                start_lnum = 1;
                end_lnum = 3;
              }
            }
  in
  TypeChecker.typecheck ast

let typecheck_decl_x_y_direction_flowers _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.DeclStmt("Jeroo", "j", {
                      a = AST.UnOpExpr(AST.New, {
                          a = AST.FxnAppExpr({
                              a = AST.IdExpr("Jeroo");
                              pos = { lnum = 2; cnum = 0; };
                            }, [
                                { a = AST.IntExpr 1; pos = { lnum = 2; cnum = 0; } };
                                { a = AST.IntExpr 1; pos = { lnum = 2; cnum = 0; } };
                                { a = AST.SouthExpr; pos = { lnum = 2; cnum = 0; } };
                                { a = AST.IntExpr 1; pos = { lnum = 2; cnum = 0; } };
                              ]
                            );
                          pos = { lnum = 2; cnum = 0; };
                        });
                      pos = { lnum = 2; cnum = 0; };
                    });
                ];
                start_lnum = 1;
                end_lnum = 3;
              }
            }
  in
  TypeChecker.typecheck ast

let typecheck_decl_bad_args _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.DeclStmt("Jeroo", "j", {
                      a = AST.UnOpExpr(AST.New, {
                          a = AST.FxnAppExpr({
                              a = AST.IdExpr("Jeroo");
                              pos = { lnum = 2; cnum = 0; };
                            }, [{ a = AST.NorthExpr; pos = { lnum = 2; cnum = 0; } }; { a = AST.SouthExpr; pos = { lnum = 2; cnum = 0; } }]);
                          pos = { lnum = 2; cnum = 0; };
                        });
                      pos = { lnum = 2; cnum = 0; };
                    });
                ];
                start_lnum = 1;
                end_lnum = 3;
              }
            }
  in
  assert_raises (Exceptions.CompileException {
      pos = { lnum = 2; cnum = 0; };
      pane = Pane.Main;
      exception_type = "error";
      message = "No match found for constructor with type: Jeroo(Compass Direction, Compass Direction)\n" ^
                "Candidate constructors:\n" ^
                "Jeroo(Number, Number)\n" ^
                "Jeroo(Number)\n" ^
                "Jeroo(Number, Number, Number)\n" ^
                "Jeroo(Number, Number, Compass Direction)\n" ^
                "Jeroo()\n" ^
                "Jeroo(Number, Number, Compass Direction, Number)";
    }) (fun () -> TypeChecker.typecheck ast)

let typecheck_if_stmt _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.IfStmt {
                    a = ({
                        a = AST.BinOpExpr({
                            a = AST.UnOpExpr(AST.Not, {
                                a = AST.TrueExpr;
                                pos = { lnum = 3; cnum = 0; };
                              });
                            pos = { lnum = 1; cnum = 0; };
                          }, AST.And, {
                              a = AST.TrueExpr;
                              pos = { lnum = 1; cnum = 0; };
                            });
                        pos = { lnum = 1; cnum = 0; };
                      }, AST.ExprStmt {
                        a = None;
                        pos = { lnum = 2; cnum = 0; }
                      });
                    pos = { lnum = 1; cnum = 0; };
                  }
                ];
                start_lnum = 1;
                end_lnum = 3;
              }
            }
  in
  TypeChecker.typecheck ast

let typecheck_if_stmt_bad_types _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.IfStmt {
                    a = ({
                        a = AST.UnOpExpr(AST.New, {
                            a = AST.FxnAppExpr(
                                {
                                  a = AST.IdExpr("Jeroo");
                                  pos = { lnum = 0; cnum = 0 }
                                }, []);
                            pos = { lnum = 0; cnum = 0; }
                          });
                        pos = { lnum = 1; cnum = 0; };
                      }, AST.ExprStmt {
                        a = None;
                        pos = { lnum = 2; cnum = 0; }
                      });
                    pos = { lnum = 1; cnum = 0; };
                  }
                ];
                start_lnum = 1;
                end_lnum = 3;
              }
            }
  in
  assert_raises (Exceptions.CompileException {
      pos = { lnum = 1; cnum = 0; };
      pane = Pane.Main;
      exception_type = "error";
      message = "If statement expected Boolean, found Jeroo";
    }) (fun () -> TypeChecker.typecheck ast)

let typecheck_while_stmt _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.WhileStmt {
                    a = ({
                        a = AST.BinOpExpr({
                            a = AST.UnOpExpr(AST.Not, {
                                a = AST.TrueExpr;
                                pos = { lnum = 3; cnum = 0; };
                              });
                            pos = { lnum = 1; cnum = 0; };
                          }, AST.And, {
                              a = AST.TrueExpr;
                              pos = { lnum = 1; cnum = 0; };
                            });
                        pos = { lnum = 1; cnum = 0; };
                      }, AST.ExprStmt {
                        a = None;
                        pos = { lnum = 2; cnum = 0; }
                      });
                    pos = { lnum = 1; cnum = 0; }
                  }
                ];
                start_lnum = 1;
                end_lnum = 3;
              }
            }
  in
  TypeChecker.typecheck ast

let typecheck_while_stmt_wrong_type _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.WhileStmt {
                    a = ({
                        a = AST.NorthExpr;
                        pos = { lnum = 1; cnum = 0; };
                      }, AST.ExprStmt {
                        a = None;
                        pos = { lnum = 2; cnum = 0; }
                      });
                    pos = { lnum = 1; cnum = 0; }
                  }
                ];
                start_lnum = 1;
                end_lnum = 3;
              }
            }
  in
  assert_raises (Exceptions.CompileException {
      pos = { lnum = 1; cnum = 0; };
      pane = Pane.Main;
      exception_type = "error";
      message = "While statement expected Boolean, found Compass Direction";
    }) (fun () -> TypeChecker.typecheck ast)

let typecheck_if_else_stmt _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.IfElseStmt {
                    a = ({
                        a = AST.BinOpExpr({
                            a = AST.UnOpExpr(AST.Not, {
                                a = AST.TrueExpr;
                                pos = { lnum = 3; cnum = 0; };
                              });
                            pos = { lnum = 1; cnum = 0; };
                          }, AST.And, {
                              a = AST.TrueExpr;
                              pos = { lnum = 1; cnum = 0; };
                            });
                        pos = { lnum = 1; cnum = 0; };
                      }, AST.ExprStmt {
                        a = None;
                        pos = { lnum = 2; cnum = 0; }
                      },
                        AST.ExprStmt {
                          a = None;
                          pos = { lnum = 2; cnum = 0; }
                        }
                      );
                    pos = { lnum = 1; cnum = 0; };
                  }
                ];
                start_lnum = 1;
                end_lnum = 3;
              }
            }
  in
  TypeChecker.typecheck ast

let typecheck_if_else_stmt_wrong_types _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.IfElseStmt {
                    a = ({
                        a = AST.NorthExpr;
                        pos = { lnum = 1; cnum = 0; };
                      }, AST.ExprStmt {
                        a = None;
                        pos = { lnum = 2; cnum = 0; }
                      },
                        AST.ExprStmt {
                          a = None;
                          pos = { lnum = 2; cnum = 0; }
                        }
                      );
                    pos = { lnum = 1; cnum = 0; };
                  }
                ];
                start_lnum = 1;
                end_lnum = 3;
              }
            }
  in
  assert_raises (Exceptions.CompileException {
      pos = { lnum = 1; cnum = 0 };
      pane = Pane.Main;
      exception_type = "error";
      message = "If statement expected Boolean, found Compass Direction";
    }) (fun () -> TypeChecker.typecheck ast)

let typecheck_extension_fxn _test_ctxt =
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
  TypeChecker.typecheck ast

let typecheck_not_wrong_types _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.ExprStmt {
                    a = Some {
                        a = AST.UnOpExpr(AST.Not, {
                            a = AST.LeftExpr;
                            pos = { lnum = 0; cnum = 0 }
                          });
                        pos = { lnum = 0; cnum = 0 }
                      };
                    pos = { lnum = 0; cnum = 0 }
                  }
                ];
                start_lnum = 1;
                end_lnum = 4;
              }
            } in
  assert_raises (Exceptions.CompileException {
      pos = { lnum = 0; cnum = 0 };
      pane = Pane.Main;
      exception_type = "error";
      message = "! operator expected: `!Boolean`, found: `!Relative Direction`";
    }) (fun () -> TypeChecker.typecheck ast)

let typecheck_and_wrong_types _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.ExprStmt {
                    a = Some {
                        a = AST.BinOpExpr({
                            a = AST.LeftExpr;
                            pos = { lnum = 0; cnum = 0 }
                          }, AST.And,
                            {
                              a = AST.RightExpr;
                              pos = { lnum = 0; cnum = 0 }
                            });
                        pos = { lnum = 0; cnum = 0 }
                      };
                    pos = { lnum = 0; cnum = 0 }
                  }
                ];
                start_lnum = 1;
                end_lnum = 4;
              }
            } in
  assert_raises (Exceptions.CompileException {
      pos = { lnum = 0; cnum = 0 };
      pane = Pane.Main;
      exception_type = "error";
      message = "&& operator expected: `Boolean && Boolean`, found: `Relative Direction && Relative Direction`";
    }) (fun () -> TypeChecker.typecheck ast)

let typecheck_unbound_identifier _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.ExprStmt {
                    a = Some {
                        a = AST.BinOpExpr({
                            a = AST.IdExpr "unbound";
                            pos = { lnum = 0; cnum = 0 }
                          }, AST.Dot,
                            {
                              a = AST.FxnAppExpr({
                                  a = IdExpr "hop";
                                  pos = { lnum = 0; cnum = 0 }
                                }, []);
                              pos = { lnum = 0; cnum = 0 }
                            });
                        pos = { lnum = 0; cnum = 0 }
                      };
                    pos = { lnum = 0; cnum = 0 }
                  }
                ];
                start_lnum = 1;
                end_lnum = 4;
              }
            } in
  assert_raises (Exceptions.CompileException {
      pos = { lnum = 0; cnum = 0 };
      pane = Pane.Main;
      exception_type = "error";
      message = "unbound not found in this scope";
    }) (fun () -> TypeChecker.typecheck ast)

let typecheck_variable_scope _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.IfStmt {
                    a = ({
                        a = AST.TrueExpr;
                        pos = { lnum = 0; cnum = 0 };
                      }, AST.DeclStmt("Jeroo", "j", {
                        a = AST.UnOpExpr(AST.New, {
                            a = AST.FxnAppExpr({
                                a = AST.IdExpr("Jeroo");
                                pos = { lnum = 0; cnum = 0 };
                              }, []);
                            pos = { lnum = 0; cnum = 0 };
                          });
                        pos = { lnum = 0; cnum = 0 };
                      });
                      );
                    pos = { lnum = 0; cnum = 0 };
                  };
                  AST.ExprStmt {
                    a = Some {
                        a = AST.BinOpExpr( {
                            a = AST.IdExpr("j");
                            pos = { lnum = 0; cnum = 0 };
                          }, AST.Dot, {
                              a = AST.FxnAppExpr( {
                                  a = AST.IdExpr("hop");
                                  pos = { lnum = 0; cnum = 0 };
                                }, [] );
                              pos = { lnum = 0; cnum = 0 };
                            } );
                        pos = { lnum = 0; cnum = 0 };
                      };
                    pos = { lnum = 0; cnum = 0 };
                  }
                ];
                start_lnum = 1;
                end_lnum = 4;
              }
            } in
  assert_raises (Exceptions.CompileException {
      pos = { lnum = 0; cnum = 0 };
      pane = Pane.Main;
      exception_type = "error";
      message = "j not found in this scope";
    }) (fun () -> TypeChecker.typecheck ast)

let typecheck_name_shadowing _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.DeclStmt("Jeroo", "j", {
                      a = AST.UnOpExpr(AST.New, {
                          a = AST.FxnAppExpr({
                              a = AST.IdExpr("Jeroo");
                              pos = { lnum = 0; cnum = 0 };
                            }, []);
                          pos = { lnum = 0; cnum = 0 };
                        });
                      pos = { lnum = 0; cnum = 0 };
                    });
                  AST.DeclStmt("Jeroo", "j", {
                      a = AST.UnOpExpr(AST.New, {
                          a = AST.FxnAppExpr({
                              a = AST.IdExpr("Jeroo");
                              pos = { lnum = 0; cnum = 0 };
                            }, []);
                          pos = { lnum = 0; cnum = 0 };
                        });
                      pos = { lnum = 0; cnum = 0 };
                    });
                ];
                start_lnum = 1;
                end_lnum = 4;
              }
            } in
  assert_raises (Exceptions.CompileException {
      pos = { lnum = 0; cnum = 0 };
      pane = Pane.Main;
      exception_type = "error";
      message = "j already declared";
    }) (fun () -> TypeChecker.typecheck ast)

let typecheck_function_shadowing_error _test_txt =
  let ast = { language = AST.Java;
              extension_fxns = [
                {
                  id = "hop";
                  stmts = [
                    AST.ExprStmt({
                        a = None;
                        pos = { lnum = 2; cnum = 0; };
                      })
                  ];
                  start_lnum = 1;
                  end_lnum = 3;
                }
              ];
              main_fxn = {
                stmts = [];
                start_lnum = 1;
                end_lnum = 4;
              }
            } in
  assert_raises (Exceptions.CompileException {
      pos = { lnum = 0; cnum = 0 };
      pane = Pane.Extensions;
      exception_type = "error";
      message = "hop() already declared";
    }) (fun () -> TypeChecker.typecheck ast)

let typecheck_function_shadowing _test_txt =
  let ast = { language = AST.Java;
              extension_fxns = [
                {
                  id = "turn";
                  stmts = [
                    AST.ExprStmt({
                        a = None;
                        pos = { lnum = 2; cnum = 0; };
                      })
                  ];
                  start_lnum = 1;
                  end_lnum = 3;
                }
              ];
              main_fxn = {
                stmts = [];
                start_lnum = 1;
                end_lnum = 4;
              }
            } in
  TypeChecker.typecheck ast

let typecheck_fxn_call_wrong_types _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.DeclStmt("Jeroo", "j", {
                      a = AST.UnOpExpr(AST.New, {
                          a = AST.FxnAppExpr({
                              a = AST.IdExpr("Jeroo");
                              pos = { lnum = 0; cnum = 0 };
                            }, []);
                          pos = { lnum = 0; cnum = 0 };
                        });
                      pos = { lnum = 0; cnum = 0 };
                    });
                  AST.ExprStmt {
                    a = Some {
                        a = AST.BinOpExpr({
                            a = AST.IdExpr("j");
                            pos = { lnum = 0; cnum = 0 };
                          }, AST.Dot, {
                              a = AST.FxnAppExpr({
                                  a = AST.IdExpr "hop";
                                  pos = { lnum = 0; cnum = 0 };
                                }, [{
                                  a = AST.LeftExpr;
                                  pos = { lnum = 0; cnum = 0 };
                                }]);
                              pos = { lnum = 0; cnum = 0 };
                            });
                        pos = { lnum = 0; cnum = 0 };
                      };
                    pos = { lnum = 0; cnum = 0 };
                  }
                ];
                start_lnum = 1;
                end_lnum = 4;
              }
            } in
  assert_raises (Exceptions.CompileException {
      pos = { lnum = 0; cnum = 0 };
      pane = Pane.Main;
      exception_type = "error";
      message = "No match found for function with type: hop(Relative Direction)\n" ^
                "Candidate functions:\n" ^
                "hop(Number)\n" ^
                "hop()";
    }) (fun () -> TypeChecker.typecheck ast)

let typecheck_fxn_call_undefined_fxn _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [];
              main_fxn = {
                stmts = [
                  AST.DeclStmt("Jeroo", "j", {
                      a = AST.UnOpExpr(AST.New, {
                          a = AST.FxnAppExpr({
                              a = AST.IdExpr("Jeroo");
                              pos = { lnum = 0; cnum = 0 };
                            }, []);
                          pos = { lnum = 0; cnum = 0 };
                        });
                      pos = { lnum = 0; cnum = 0 };
                    });
                  AST.ExprStmt {
                    a = Some {
                        a = AST.BinOpExpr({
                            a = AST.IdExpr("j");
                            pos = { lnum = 0; cnum = 0 };
                          }, AST.Dot, {
                              a = AST.FxnAppExpr({
                                  a = AST.IdExpr "fizzbuzz";
                                  pos = { lnum = 0; cnum = 0 };
                                }, [{
                                  a = AST.LeftExpr;
                                  pos = { lnum = 0; cnum = 0 };
                                }]);
                              pos = { lnum = 0; cnum = 0 };
                            });
                        pos = { lnum = 0; cnum = 0 };
                      };
                    pos = { lnum = 0; cnum = 0 };
                  }
                ];
                start_lnum = 1;
                end_lnum = 4;
              }
            } in
  assert_raises (Exceptions.CompileException {
      pos = { lnum = 0; cnum = 0 };
      pane = Pane.Main;
      exception_type = "error";
      message = "fizzbuzz not found in this scope"
    }) (fun () -> TypeChecker.typecheck ast)

let typecheck_type_error_in_extensions _test_ctxt =
  let ast = { language = AST.Java;
              extension_fxns = [
                {
                  id = "foo";
                  stmts = [
                    AST.ExprStmt({
                        a = Some {
                            a = AST.BinOpExpr({
                                a = AST.TrueExpr;
                                pos = { lnum = 2; cnum = 0; };
                              }, AST.Or, {
                                  a = AST.NorthExpr;
                                  pos = { lnum = 2; cnum = 0; };
                                });
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
                stmts = [];
                start_lnum = 1;
                end_lnum = 4;
              }
            } in
  assert_raises (Exceptions.CompileException {
      pos = { lnum = 2; cnum = 0 };
      pane = Pane.Extensions;
      exception_type = "error";
      message = "|| operator expected: `Boolean || Boolean`, found: `Boolean || Compass Direction`";
    }) (fun () -> TypeChecker.typecheck ast)

let typecheck_dot_wrong_types _test_ctxt =
  let ast = {
    language = AST.Java;
    extension_fxns = [];
    main_fxn = {
      stmts = [
        AST.ExprStmt({
            a = Some({
                a = AST.BinOpExpr({
                    a = AST.IntExpr(1);
                    pos = { lnum = 3; cnum = 0; };
                  }, AST.Dot, {
                      a = AST.IntExpr(2);
                      pos = { lnum = 3; cnum = 0; };
                    });
                pos = { lnum = 3; cnum = 0; };
              });
            pos = { lnum = 3; cnum = 0; };
          })
      ];
      start_lnum = 1;
      end_lnum = 1;
    }
  }
  in
  assert_raises (Exceptions.CompileException {
      pos = { lnum = 3; cnum = 0 };
      pane = Pane.Main;
      exception_type = "error";
      message = ". operator must be used with a Jeroo object, found Number";
    }) (fun () -> TypeChecker.typecheck ast)

let typecheck_out_of_order_fxn_call _test_ctxt =
  let ast = {
    language = AST.Java;
    extension_fxns = [
      {
        id = "foo";
        stmts = [
          AST.ExprStmt {
            a = Some {
                a = AST.FxnAppExpr ({
                    a = AST.IdExpr "bar";
                    pos = { lnum = 0; cnum = 0 }
                  }, []);
                pos = { lnum = 0; cnum = 0 }
              };
            pos = { lnum = 0; cnum = 0; }
          }
        ];
        start_lnum = 0;
        end_lnum = 0;
      };
      {
        id = "bar";
        stmts = [];
        start_lnum = 0;
        end_lnum = 0;
      }
    ];
    main_fxn = {
      stmts = [];
      start_lnum = 0;
      end_lnum = 0;
    }
  }
  in
  TypeChecker.typecheck ast

let suite =
  "TypeChecker">::: [
    "Typecheck decl no args">:: typecheck_decl_no_args;
    "Typecheck decl flowers">:: typecheck_decl_flowers;
    "Typecheck decl x y">:: typecheck_decl_x_y;
    "Typecheck decl x y flowers">:: typecheck_decl_x_y_flowers;
    "Typecheck decl x y direction">:: typecheck_decl_x_y_direction;
    "Typecheck decl x y direction flowers">:: typecheck_decl_x_y_direction_flowers;
    "Typecheck decl with bad args">:: typecheck_decl_bad_args;
    "Typecheck if stmt">:: typecheck_if_stmt;
    "Typecheck if stmt wrong types">:: typecheck_if_stmt_bad_types;
    "Typecheck if else stmt">:: typecheck_if_else_stmt;
    "Typecheck if else stmt wrong types">:: typecheck_if_else_stmt_wrong_types;
    "Typecheck while stmt">:: typecheck_while_stmt;
    "Typecheck while stmt wrong types">:: typecheck_while_stmt_wrong_type;
    "Typecheck extension fxn">:: typecheck_extension_fxn;
    "Typecheck not expr wrong types">:: typecheck_not_wrong_types;
    "Typecheck and expr wrong types">:: typecheck_and_wrong_types;
    "Typecheck unbound identifier">:: typecheck_unbound_identifier;
    "Typecheck variable scope">:: typecheck_variable_scope;
    "Typecheck name shadowing">:: typecheck_name_shadowing;
    "Typecheck function shadowing error">:: typecheck_function_shadowing_error;
    "Typecheck function shadowing">:: typecheck_function_shadowing;
    "Typecheck function call with wrong types">:: typecheck_fxn_call_wrong_types;
    "Typecheck undefined function">:: typecheck_fxn_call_undefined_fxn;
    "Typecheck error in extensions">:: typecheck_type_error_in_extensions;
    "Typecheck dot expr wrong types">:: typecheck_dot_wrong_types;
    "Typecheck functions called out of lexical order">:: typecheck_out_of_order_fxn_call;
  ]
