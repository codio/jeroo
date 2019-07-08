%{
open AST
%}
%token <int * Position.t> INT
%token <string * Position.t> ID
%token <Position.t> SUB IF ELSE WHILE END ELSEIF
%token <Position.t> AND OR NOT EQ NEW DOT
%token <Position.t> LEFT RIGHT AHEAD HERE TRUE FALSE
%token <Position.t> NORTH SOUTH EAST WEST
%token <Position.t> LPAREN RPAREN COMMA THEN DIM AS
%token <Position.t> NEWLINE
%token HEADER MAIN_METH_SEP
%token EOF

%left OR
%left AND
%right NEW
%right NOT
%left DOT

%start <AST.translation_unit> translation_unit

%%

translation_unit:
  | HEADER NEWLINE? fs = fxn* MAIN_METH_SEP NEWLINE? f = fxn EOF
    { { extension_fxns = fs; main_fxn = f; language = AST.VB; } }

fxn:
  | start_pos = SUB id_pos = ID LPAREN RPAREN NEWLINE stmts = block end_pos = END SUB NEWLINE
    {
      {
        id = fst id_pos;
        stmts;
        start_lnum = start_pos.lnum;
        end_lnum = end_pos.lnum;
      }
    }

block:
  | stmts = stmt* { stmts }

stmt:
(* if statement *)
  | pos = IF e = expr THEN NEWLINE b = block END IF NEWLINE
    { AST.IfStmt{ a = (e, AST.BlockStmt(b)); pos } }
(* else-if statement *)
  | pos = IF e = expr THEN NEWLINE b1 = block s = elseif_stmt
    { AST.IfElseStmt{ a = (e, AST.BlockStmt(b1), s); pos } }
(* if-else statement *)
  | pos = IF e = expr THEN NEWLINE b1 = block ELSE NEWLINE b2 = block END IF NEWLINE
    { AST.IfElseStmt{ a = (e, AST.BlockStmt(b1), AST.BlockStmt(b2)); pos } }
(* while statement *)
  | pos = WHILE e = expr NEWLINE b = block END WHILE NEWLINE
    { AST.WhileStmt{ a = (e, AST.BlockStmt(b)); pos } }
(* variable declaration statement *)
  | DIM id = ID AS ty = ID EQ e = expr NEWLINE
    { let (id, _) = id in let (ty, _) = ty in AST.DeclStmt(ty, id, e) }
(* expression statement *)
  | e = expr pos = NEWLINE
    { AST.ExprStmt({ a = Some e; pos }) }

elseif_stmt:
  | pos = ELSEIF e = expr THEN NEWLINE b = block elseif = elseif_stmt
    { AST.IfElseStmt{ a = (e, AST.BlockStmt(b), elseif); pos } }
  | pos = ELSEIF e = expr THEN NEWLINE b1 = block ELSE NEWLINE b2 = block END IF NEWLINE
    { AST.IfElseStmt{ a = (e, AST.BlockStmt(b1), AST.BlockStmt(b2)); pos } }
  | pos = ELSEIF e = expr THEN NEWLINE b = block END IF NEWLINE
    { AST.IfStmt{ a = (e, AST.BlockStmt(b)); pos } }

arguments:
  | args = separated_list(COMMA, expr) { args }

expr:
  | e = arith_expr { e }
  | id_pos = ID LPAREN args = arguments RPAREN
    { { a = AST.FxnAppExpr({ a = (AST.IdExpr (fst id_pos)); pos = snd id_pos }, args); pos = snd id_pos } }

arith_expr:
  | e = primary_expr { e }
  | e1 = expr pos = AND e2 = expr { { a = AST.BinOpExpr(e1, AST.And, e2); pos } }
  | e1 = expr pos = OR e2 = expr { { a = AST.BinOpExpr(e1, AST.Or, e2); pos } }
  | e1 = expr pos = DOT e2 = expr { { a = AST.BinOpExpr(e1, AST.Dot, e2); pos } }
  | pos = NEW e = expr { { a = AST.UnOpExpr(AST.New, e); pos } }
  | pos = NOT e = expr { { a = AST.UnOpExpr(AST.Not, e); pos } }

primary_expr:
  | id_pos = ID { { a = AST.IdExpr(fst id_pos); pos = snd id_pos } }
  | i_pos = INT { { a = AST.IntExpr(fst i_pos); pos = snd i_pos } }
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
