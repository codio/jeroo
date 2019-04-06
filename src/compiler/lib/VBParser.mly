%{
open AST
%}
%token <int * int> INT
%token <string * int> ID
%token <int> SUB IF ELSE WHILE END ELSEIF
%token <int> AND OR NOT EQ NEW DOT
%token <int> LEFT RIGHT AHEAD HERE TRUE FALSE
%token <int> NORTH SOUTH EAST WEST
%token <int> LPAREN RPAREN COMMA THEN DIM AS
%token <int> NEWLINE
%token HEADER MAIN_METH_SEP
%token EOF

%right EQ
%left OR
%left AND
%right NEW
%right NOT
%left DOT

%start <AST.translation_unit> translation_unit

%on_error_reduce list(NEWLINE)
%on_error_reduce nonempty_list(NEWLINE)
%on_error_reduce list(stmt)
%on_error_reduce expr
%%

translation_unit:
  | HEADER NEWLINE* fs = fxns MAIN_METH_SEP NEWLINE* f = fxn NEWLINE* EOF { { extension_fxns = fs; main_fxn = f} }

fxns:
  |  fs = extension_fxn*  { fs }

extension_fxn:
  | f = fxn NEWLINE+ { f }

fxn:
  | start_lnum = SUB id = ID LPAREN RPAREN NEWLINE b = block end_lnum = END SUB {
        let (id, _) = id in
        let stmts = b in
        {
          id = id;
          stmts = stmts;
          start_lnum = start_lnum;
          end_lnum = end_lnum
        }
      }

block:
  | stmts = stmt* { stmts }

stmt:
(* if statement, no parenthesis *)
  | ln = IF e = expr THEN NEWLINE b = block END IF NEWLINE { AST.IfStmt(e, AST.BlockStmt(b), ln) }
(* else-if statement, no parenthesis *)
  | ln = IF e = expr THEN NEWLINE b1 = block s = elseif_stmt { AST.IfElseStmt(e, AST.BlockStmt(b1), s, ln) }
(* if-else statement, no parenthesis *)
  | ln = IF e = expr THEN NEWLINE b1 = block ELSE NEWLINE b2 = block END IF NEWLINE { AST.IfElseStmt(e, AST.BlockStmt(b1), AST.BlockStmt(b2), ln) }
(* while statement, no parenthesis *)
  | ln = WHILE e = expr NEWLINE b = block END WHILE NEWLINE { AST.WhileStmt(e, AST.BlockStmt(b), ln) }
(* variable declaration statement *)
  | DIM id = ID AS ty = ID EQ e = expr NEWLINE { let (id, _) = id in let (ty, _) = ty in AST.DeclStmt(ty, id, e) }
(* expression statement *)
  | e = expr? ln = NEWLINE { AST.ExprStmt({a = e; lnum = ln}) }

elseif_stmt:
  | ln = ELSEIF e = expr THEN NEWLINE b = block elseif = elseif_stmt { AST.IfElseStmt(e, AST.BlockStmt(b), elseif, ln) }
  | ln = ELSEIF e = expr THEN NEWLINE b1 = block ELSE NEWLINE b2 = block END IF NEWLINE { AST.IfElseStmt(e, AST.BlockStmt(b1), AST.BlockStmt(b2), ln) }
  | ln = ELSEIF e = expr THEN NEWLINE b = block END IF NEWLINE { AST.IfStmt(e, AST.BlockStmt(b), ln) }

arguments:
  | args = separated_list(COMMA, expr) { args }

expr:
  | e = arith_expr { e }
  | id_ln = ID ln = LPAREN args = arguments RPAREN { let (id, idln) = id_ln in { a = AST.FxnAppExpr({ a = (AST.IdExpr id); lnum = idln }, args); lnum = ln } }

arith_expr:
  | e = primary_expr { e }
  | e1 = expr ln = AND e2 = expr { { a = AST.BinOpExpr(e1, AST.And, e2); lnum = ln } }
  | e1 = expr ln = OR e2 = expr { { a = AST.BinOpExpr(e1, AST.Or, e2); lnum = ln } }
  | e1 = expr ln = DOT e2 = expr { { a = AST.BinOpExpr(e1, AST.Dot, e2); lnum = ln } }
  | e1 = expr ln = EQ e2 = expr { { a = AST.BinOpExpr(e1, AST.Eq, e2); lnum = ln } }
  | ln = NEW e = expr { { a = AST.UnOpExpr(AST.New, e); lnum = ln } }
  | ln = NOT e = expr { { a = AST.UnOpExpr(AST.Not, e); lnum = ln } }

primary_expr:
  | id_ln = ID { let (id, ln) = id_ln in { a = AST.IdExpr(id); lnum = ln } }
  | i_ln = INT { let (i, ln) = i_ln in { a = AST.IntExpr(i); lnum = ln } }
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
