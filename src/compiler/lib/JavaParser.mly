%{
open AST
%}
%token <int * int> INT
%token <string * int> ID
%token <int> TRUE FALSE
%token <int> NOT AND OR EQ
%token <int> METHOD IF ELSE WHILE NEW
%token <int> LPAREN RPAREN
%token <int> LBRACKET RBRACKET
%token <int> COMMA DOT SEMICOLON
%token <int> LEFT RIGHT AHEAD HERE
%token <int> NORTH EAST SOUTH WEST
%token HEADER MAIN_METH_SEP
%token EOF

%right EQ
%left OR
%left AND
%right NEW
%right NOT
%left DOT

%start <AST.translation_unit> translation_unit

%on_error_reduce expr
%%

translation_unit:
  | HEADER fs = fxn* MAIN_METH_SEP f = fxn EOF { { extension_fxns = fs; main_fxn = f } }

fxn:
  | METHOD id = ID LPAREN RPAREN b = block {
                                         let (id, _) = id in
                                         let (stmts, start_lnum, end_lnum) = b in
                                         {
                                           id = id;
                                           stmts = stmts;
                                           start_lnum = start_lnum;
                                           end_lnum = end_lnum;
                                         }
                                       }

block:
  | start_lnum = LBRACKET stmts = stmt* end_lnum = RBRACKET { (stmts, start_lnum, end_lnum) }

stmt: | s = open_stmt { s }
  | s = closed_stmt { s }

open_stmt:
  | ln = IF LPAREN e = expr RPAREN s = stmt { AST.IfStmt(e, s, ln) }
  | ln = IF LPAREN e = expr RPAREN s1 = closed_stmt ELSE s2 = open_stmt { AST.IfElseStmt(e, s1, s2, ln) }
  | ln = WHILE LPAREN e = expr RPAREN s = open_stmt { AST.WhileStmt(e, s, ln) }

closed_stmt:
  | s = simple_stmt { s }
  | ln = IF LPAREN e = expr RPAREN s1 = closed_stmt ELSE s2 = closed_stmt { AST.IfElseStmt(e, s1, s2, ln) }
  | ln = WHILE LPAREN e = expr RPAREN s = closed_stmt { AST.WhileStmt(e, s, ln) }

simple_stmt:
  | b = block { let (stmts, _, _) = b in AST.BlockStmt(stmts) }
  | ty = ID id = ID EQ e = expr SEMICOLON { let (id, _) = id in let (ty, _) = ty in AST.DeclStmt(ty, id, e) }
  | e = expr SEMICOLON { AST.ExprStmt(e) }

arguments:
  | args = separated_list(COMMA, expr) { args }

expr:
  | e = arith_expr { e }
  | e = arith_expr ln = LPAREN args = arguments RPAREN { { a = AST.FxnAppExpr(e, args); lnum = ln } }

arith_expr:
  | e = primary_expr { e }
  | e1 = expr ln = AND e2 = expr { { a = AST.BinOpExpr(e1, AST.And, e2); lnum = ln } }
  | e1 = expr ln = OR e2 = expr { { a = AST.BinOpExpr(e1, AST.Or, e2); lnum = ln } }
  | e1 = expr ln = DOT e2 = expr { { a = AST.BinOpExpr(e1, AST.Dot, e2); lnum = ln } }
  | e1 = expr ln = EQ e2 = expr { { a = AST.BinOpExpr(e1, AST.Eq, e2); lnum = ln } }
  | ln = NEW e = expr { { a = AST.UnOpExpr (AST.New, e); lnum = ln } }
  | ln = NOT e = expr { { a = AST.UnOpExpr(AST.Not, e); lnum = ln } }

primary_expr:
  | id_ln = ID { let (id, ln) = id_ln in { a = (AST.IdExpr id); lnum = ln } }
  | i_ln = INT { let (i, ln) = i_ln in { a = (AST.IntExpr i); lnum = ln } }
  | ln = TRUE { { a = AST.TrueExpr; lnum = ln } }
  | ln = FALSE { { a = AST.FalseExpr; lnum = ln } }
  | ln = LEFT { { a = AST.LeftExpr; lnum = ln } }
  | ln = RIGHT { { a = AST.RightExpr; lnum = ln } }
  | ln = AHEAD { { a = AST.AheadExpr; lnum = ln } }
  | ln = HERE { { a = AST.HereExpr; lnum = ln } }
  | ln = NORTH { { a = AST.NorthExpr; lnum = ln } }
  | ln = EAST { { a = AST.EastExpr; lnum = ln } }
  | ln = SOUTH { { a = AST.SouthExpr; lnum = ln } }
  | ln = WEST { { a = AST.WestExpr; lnum = ln } }
  | LPAREN e = expr RPAREN { e }
