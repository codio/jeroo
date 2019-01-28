%token <int> INT
%token <string> ID
%token SUB IF ELSE WHILE END ELSEIF
%token AND OR NOT EQ NEW DOT
%token LEFT RIGHT AHEAD HERE TRUE FALSE
%token NORTH SOUTH EAST WEST
%token LPAREN RPAREN COMMA THEN DIM AS NEWLINE
%token EOF

%right EQ
%left OR
%left AND
%right NEW
%right NOT
%left DOT

%start <AST.fxn list> translation_unit
%%

translation_unit:
| fs = fxns EOF { fs }

fxns:
| NEWLINE? { [] }
| NEWLINE? f = fxn fs = fxns NEWLINE? { f :: fs }

fxn:
| SUB id = ID LPAREN RPAREN b = block END SUB { (id, b) }

block:
| NEWLINE stmts = stmt* { stmts }

stmt:
(* if statment *)
| IF LPAREN e = expr RPAREN THEN b = block END IF NEWLINE { `IfStmt(e, `BlockStmt(b)) }
(* if statment, no parenthesis *)
| IF e = expr THEN b = block END IF NEWLINE { `IfStmt(e, `BlockStmt(b)) }
(* if-else statment *)
| IF LPAREN e = expr RPAREN THEN b1 = block ELSE b2 = block END IF NEWLINE { `IfElseStmt(e, `BlockStmt(b1), `BlockStmt(b2)) }
(* else-if statement *)
| IF LPAREN e = expr RPAREN THEN b1 = block s = elseif_stmt NEWLINE { `IfElseStmt(e, `BlockStmt(b1), s) }
(* else-if statement, no parenthesis *)
| IF e = expr THEN b1 = block s = elseif_stmt NEWLINE { `IfElseStmt(e, `BlockStmt(b1), s) }
(* if-else statement, no parenthesis *)
| IF e = expr THEN b1 = block ELSE b2 = block END IF NEWLINE { `IfElseStmt(e, `BlockStmt(b1), `BlockStmt(b2)) }
(* while statement *)
| WHILE LPAREN e = expr RPAREN b = block END WHILE NEWLINE { `WhileStmt(e, `BlockStmt(b)) }
(* while statement, no parenthesis *)
| WHILE e = expr b = block END WHILE NEWLINE { `WhileStmt(e, `BlockStmt(b)) }
(* variable declaration statement *)
| DIM id = ID AS ty = ID EQ e = expr NEWLINE { `DeclStmt(ty, id, e) }
(* expression statement *)
| e = expr NEWLINE { `ExprStmt(e) }

elseif_stmt:
| ELSEIF LPAREN e = expr RPAREN THEN b = block elseif = elseif_stmt { `IfElseStmt(e, `BlockStmt(b), elseif) }
| ELSEIF e = expr THEN b = block elseif = elseif_stmt { `IfElseStmt(e, `BlockStmt(b), elseif) }
| ELSEIF LPAREN e = expr RPAREN THEN b1 = block ELSE b2 = block END IF { `IfElseStmt(e, `BlockStmt(b1), `BlockStmt(b2)) }
| ELSEIF e = expr THEN b1 = block ELSE b2 = block END IF { `IfElseStmt(e, `BlockStmt(b1), `BlockStmt(b2)) }
| ELSEIF LPAREN e = expr RPAREN THEN b = block END IF { `IfStmt(e, `BlockStmt(b)) }
| ELSEIF e = expr THEN b = block END IF { `IfStmt(e, `BlockStmt(b)) }

expr:
| e = arith_expr { e }
| e = arith_expr LPAREN args = arguments RPAREN { `FxnAppExpr(e, args) }

arith_expr:
| e = primary_expr { e }
| e1 = expr AND e2 = expr { `BinOpExpr(e1, `And, e2) }
| e1 = expr OR e2 = expr { `BinOpExpr(e1, `Or, e2) }
| e1 = expr DOT e2 = expr { `BinOpExpr(e1, `Dot, e2) }
| e1 = expr EQ e2 = expr { `BinOpExpr(e1, `Eq, e2) }
| NOT e = expr { `UnOpExpr(`Not, e) }
| NEW e = expr { `UnOpExpr(`New, e) }

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
| SOUTH { `SouthExpr }
| EAST { `EastExpr }
| WEST { `WestExpr }
| LPAREN e = expr RPAREN { e }

arguments:
| args = separated_list(COMMA, expr) { args }
