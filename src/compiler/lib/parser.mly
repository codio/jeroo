%token <int> INT
%token <string> ID
%token TRUE FALSE
%token NOT AND OR
%token EQ
%token METHOD IF ELSE WHILE NEW
%token LPAREN RPAREN
%token LBRACKET RBRACKET
%token COMMA DOT SEMICOLON
%token LEFT RIGHT AHEAD HERE
%token NORTH EAST SOUTH WEST
%token JEROO
%token EOF

%left OR
%left AND
%right NEW
%right NOT
%left DOT

%start <AST.fxn list> translation_unit

%%

translation_unit:
| fs = fxn+ EOF { fs }

fxn:
| METHOD id = ID LPAREN RPAREN b = block { (id, b) }

block:
| LBRACKET decls = decl* stmts = stmt* RBRACKET { (decls, stmts) }

decl:
| JEROO id = ID EQ NEW JEROO LPAREN args = arguments RPAREN SEMICOLON { ("Jeroo", id, `UnOpExpr(`New, `FxnAppExpr(`IdExpr("Jeroo"), args))) }


stmt:
| s = open_stmt { s }
| s = closed_stmt { s }

open_stmt:
| IF LPAREN e = expr RPAREN s = stmt { `IfStmt(e, s) }
| IF LPAREN e = expr RPAREN s1 = closed_stmt ELSE s2 = open_stmt { `IfElseStmt(e, s1, s2) }
| WHILE LPAREN e = expr RPAREN s = open_stmt { `WhileStmt(e, s) }

closed_stmt:
| s = simple_stmt { s }
| IF LPAREN e = expr RPAREN s1 = closed_stmt ELSE s2 = closed_stmt { `IfElseStmt(e, s1, s2) }
| WHILE LPAREN e = expr RPAREN s = closed_stmt { `WhileStmt(e, s) }

simple_stmt:
| b = block { `BlockStmt(b) }
| e = expr SEMICOLON { `ExprStmt(e) }

arguments:
| args = separated_list(COMMA, expr) { args }

expr:
| e = arith_expr { e }
| e = arith_expr LPAREN args = arguments RPAREN { `FxnAppExpr(e, args) }
| e1 = arith_expr EQ e2 = arith_expr { `BinOpExpr(e1, `Eq, e2) }

arith_expr:
| e = primary_expr { e }
| e1 = expr AND e2 = expr { `BinOpExpr(e1, `And, e2) }
| e1 = expr OR e2 = expr { `BinOpExpr(e1, `Or, e2) }
| e1 = expr DOT e2 = expr { `BinOpExpr(e1, `Dot, e2) }
| NEW e = expr { `UnOpExpr (`New, e) }
| NOT e = expr { `UnOpExpr(`Not, e) }

primary_expr:
| id = ID { `IdExpr(id) }
| i = INT { `IntExpr(i) }
| TRUE { `TrueExpr }
| FALSE { `FalseExpr }
| LEFT { `LeftExpr }
| RIGHT { `RightExpr }
| AHEAD { `AheadExpr }
| HERE { `HereExpr }
| NORTH { `NorthExpr }
| EAST { `EastExpr }
| SOUTH { `SouthExpr }
| WEST { `WestExpr }
| LPAREN e = expr RPAREN { e }
