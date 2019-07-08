%{
open AST
%}
%token <int * Position.t> INT
%token <string * Position.t> ID
%token <Position.t> TRUE FALSE
%token <Position.t> NOT AND OR EQ
%token <Position.t> METHOD IF ELSE WHILE NEW
%token <Position.t> LPAREN RPAREN
%token <Position.t> LBRACKET RBRACKET
%token <Position.t> COMMA DOT SEMICOLON
%token <Position.t> LEFT RIGHT AHEAD HERE
%token <Position.t> NORTH EAST SOUTH WEST
%token HEADER MAIN_METH_SEP
%token EOF

%left OR
%left AND
%right NEW
%right NOT
%left DOT

%start <AST.translation_unit> translation_unit

%on_error_reduce expr
%%

translation_unit:
  | HEADER fs = fxn* MAIN_METH_SEP f = fxn EOF { { extension_fxns = fs; main_fxn = f; language = AST.Java; } }

fxn:
  | METHOD id_pos = ID LPAREN RPAREN b = block {
                                         let (stmts, start_lnum, end_lnum) = b in
                                         {
                                           id = fst id_pos;
                                           stmts;
                                           start_lnum;
                                           end_lnum;
                                         }
                                       }

block:
  | start_pos = LBRACKET stmts = stmt* end_pos = RBRACKET { (stmts, start_pos.lnum, end_pos.lnum) }

stmt:
  | s = open_stmt { s }
  | s = closed_stmt { s }

open_stmt:
  | pos = IF LPAREN e = expr RPAREN s = stmt { AST.IfStmt{ a = (e, s); pos } }
  | pos = IF LPAREN e = expr RPAREN s1 = closed_stmt ELSE s2 = open_stmt { AST.IfElseStmt{ a = (e, s1, s2); pos } }
  | pos = WHILE LPAREN e = expr RPAREN s = open_stmt { AST.WhileStmt{ a = (e, s); pos } }

closed_stmt:
  | s = simple_stmt { s }
  | pos = IF LPAREN e = expr RPAREN s1 = closed_stmt ELSE s2 = closed_stmt { AST.IfElseStmt{ a = (e, s1, s2); pos } }
  | pos = WHILE LPAREN e = expr RPAREN s = closed_stmt { AST.WhileStmt{ a = (e, s); pos } }

simple_stmt:
  | b = block { let (stmts, _, _) = b in AST.BlockStmt(stmts) }
  | ty_pos = ID id_pos = ID EQ e = expr SEMICOLON { AST.DeclStmt(fst ty_pos, fst id_pos, e) }
  | e = expr? pos = SEMICOLON { AST.ExprStmt({ a = e; pos }) }

arguments:
  | args = separated_list(COMMA, expr) { args }

expr:
  | e = arith_expr { e }
  | id_pos = ID LPAREN args = arguments RPAREN { { a = AST.FxnAppExpr({ a = AST.IdExpr (fst id_pos); pos = snd id_pos }, args); pos = snd id_pos } }

arith_expr:
  | e = primary_expr { e }
  | e1 = expr pos = AND e2 = expr { { a = AST.BinOpExpr(e1, AST.And, e2); pos } }
  | e1 = expr pos = OR e2 = expr { { a = AST.BinOpExpr(e1, AST.Or, e2); pos } }
  | e1 = expr pos = DOT e2 = expr { { a = AST.BinOpExpr(e1, AST.Dot, e2); pos } }
  | pos = NEW e = expr { { a = AST.UnOpExpr (AST.New, e); pos } }
  | pos = NOT e = expr { { a = AST.UnOpExpr(AST.Not, e); pos } }

primary_expr:
  | id_pos = ID { { a = AST.IdExpr (fst id_pos); pos = snd id_pos } }
  | i_pos = INT { { a = AST.IntExpr (fst i_pos); pos = snd i_pos } }
  | pos = TRUE { { a = AST.TrueExpr; pos } }
  | pos = FALSE { { a = AST.FalseExpr; pos } }
  | pos = LEFT { { a = AST.LeftExpr; pos } }
  | pos = RIGHT { { a = AST.RightExpr; pos } }
  | pos = AHEAD { { a = AST.AheadExpr; pos } }
  | pos = HERE { { a = AST.HereExpr; pos } }
  | pos = NORTH { { a = AST.NorthExpr; pos } }
  | pos = EAST { { a = AST.EastExpr; pos } }
  | pos = SOUTH { { a = AST.SouthExpr; pos } }
  | pos = WEST { { a = AST.WestExpr; pos } }
  | LPAREN e = expr RPAREN { e }
