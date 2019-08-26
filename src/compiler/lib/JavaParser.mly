%{
open AST
%}
%token <int * Position.t> INT
%token <string * Position.t> ID
%token <Position.t * string> TRUE FALSE
%token <Position.t * string> NOT AND OR EQ
%token <Position.t * string> METHOD IF ELSE WHILE NEW
%token <Position.t * string> LPAREN RPAREN
%token <Position.t * string> LBRACKET RBRACKET
%token <Position.t * string> COMMA DOT SEMICOLON
%token <Position.t * string> LEFT RIGHT AHEAD HERE
%token <Position.t * string> NORTH EAST SOUTH WEST
%token EOF

%left OR
%left AND
%right NEW
%right NOT
%left DOT

%start <AST.fxn AST.meta list> translation_unit

%on_error_reduce expr
%%

translation_unit:
  | fs = fxn* EOF { fs }

fxn:
  | pos_s = METHOD id_pos = ID LPAREN RPAREN stmts = block
    {
      {
        a = {
          stmts;
          id = fst id_pos;
        };
        pos = fst pos_s
      }
    }

block:
  | LBRACKET stmts = stmt* RBRACKET { stmts }

stmt:
  | s = open_stmt { s }
  | s = closed_stmt { s }

open_stmt:
  | pos_s = IF LPAREN e = expr RPAREN s = stmt { AST.IfStmt{ a = (e, s); pos = fst pos_s } }
  | pos_s = IF LPAREN e = expr RPAREN s1 = closed_stmt ELSE s2 = open_stmt { AST.IfElseStmt{ a = (e, s1, s2); pos  = fst pos_s } }
  | pos_s = WHILE LPAREN e = expr RPAREN s = open_stmt { AST.WhileStmt{ a = (e, s); pos = fst pos_s } }

closed_stmt:
  | s = simple_stmt { s }
  | pos_s = IF LPAREN e = expr RPAREN s1 = closed_stmt ELSE s2 = closed_stmt { AST.IfElseStmt{ a = (e, s1, s2); pos = fst pos_s } }
  | pos_s = WHILE LPAREN e = expr RPAREN s = closed_stmt { AST.WhileStmt{ a = (e, s); pos = fst pos_s } }

simple_stmt:
  | stmts = block { AST.BlockStmt(stmts) }
  | ty_pos = ID id_pos = ID EQ e = expr SEMICOLON { AST.DeclStmt(fst ty_pos, fst id_pos, e) }
  | e = expr? pos_s = SEMICOLON { AST.ExprStmt({ a = e; pos = fst pos_s }) }

arguments:
  | args = separated_list(COMMA, expr) { args }

expr:
  | e = arith_expr { e }
  | id_pos = ID LPAREN args = arguments RPAREN { { a = AST.FxnAppExpr({ a = AST.IdExpr (fst id_pos); pos = snd id_pos }, args); pos = snd id_pos } }

arith_expr:
  | e = primary_expr { e }
  | e1 = expr pos_s = AND e2 = expr { { a = AST.BinOpExpr(e1, (AST.And, (snd pos_s)), e2); pos = fst pos_s } }
  | e1 = expr pos_s = OR e2 = expr { { a = AST.BinOpExpr(e1, (AST.Or, (snd pos_s)), e2); pos = fst pos_s } }
  | e1 = expr pos_s = DOT e2 = expr { { a = AST.BinOpExpr(e1, (AST.Dot, (snd pos_s)), e2); pos = fst pos_s } }
  | pos_s = NEW e = expr { { a = AST.UnOpExpr ((AST.New, (snd pos_s)), e); pos = fst pos_s } }
  | pos_s = NOT e = expr { { a = AST.UnOpExpr((AST.Not, (snd pos_s)), e); pos = fst pos_s } }

primary_expr:
  | id_pos = ID { { a = AST.IdExpr (fst id_pos); pos = snd id_pos } }
  | i_pos = INT { { a = AST.IntExpr (fst i_pos); pos = snd i_pos } }
  | pos_s = TRUE { { a = AST.TrueExpr; pos = fst pos_s } }
  | pos_s = FALSE { { a = AST.FalseExpr; pos = fst pos_s } }
  | pos_s = LEFT { { a = AST.LeftExpr; pos = fst pos_s } }
  | pos_s = RIGHT { { a = AST.RightExpr; pos = fst pos_s } }
  | pos_s = AHEAD { { a = AST.AheadExpr; pos = fst pos_s } }
  | pos_s = HERE { { a = AST.HereExpr; pos = fst pos_s } }
  | pos_s = NORTH { { a = AST.NorthExpr; pos = fst pos_s } }
  | pos_s = EAST { { a = AST.EastExpr; pos = fst pos_s } }
  | pos_s = SOUTH { { a = AST.SouthExpr; pos = fst pos_s } }
  | pos_s = WEST { { a = AST.WestExpr; pos = fst pos_s } }
  | LPAREN e = expr RPAREN { e }
