%{
open AST
%}
%token <int * Position.t> INT
%token <string * Position.t> ID
%token <Position.t * string> SUB IF ELSE WHILE ELSEIF ENDIF ENDWHILE ENDSUB
%token <Position.t * string> AND OR NOT EQ NEW DOT
%token <Position.t * string> LEFT RIGHT AHEAD HERE TRUE FALSE
%token <Position.t * string> NORTH SOUTH EAST WEST
%token <Position.t * string> LPAREN RPAREN COMMA THEN DIM AS
%token <Position.t> NEWLINE
%token EOF

%left OR
%left AND
%right NEW
%right NOT
%left DOT

%start <AST.fxn AST.meta list> translation_unit

%%

translation_unit:
  | NEWLINE? fs = fxn* EOF
    { fs }

fxn:
  | pos_s = SUB id_pos = ID LPAREN RPAREN NEWLINE stmts = block ENDSUB NEWLINE
    {
      {
        a = {
          id = fst id_pos;
          stmts;
        };
        pos = fst pos_s
      }
    }

block:
  | stmts = stmt* { stmts }

stmt:
(* if statement *)
  | pos_s = IF e = expr THEN NEWLINE b = block ENDIF NEWLINE
    { AST.IfStmt{ a = (e, AST.BlockStmt(b)); pos = fst pos_s } }
(* else-if statement *)
  | pos_s = IF e = expr THEN NEWLINE b1 = block s = elseif_stmt
    { AST.IfElseStmt{ a = (e, AST.BlockStmt(b1), s); pos = fst pos_s } }
(* if-else statement *)
  | pos_s = IF e = expr THEN NEWLINE b1 = block ELSE NEWLINE b2 = block ENDIF NEWLINE
    { AST.IfElseStmt{ a = (e, AST.BlockStmt(b1), AST.BlockStmt(b2)); pos = fst pos_s } }
(* while statement *)
  | pos_s = WHILE e = expr NEWLINE b = block ENDWHILE NEWLINE
    { AST.WhileStmt{ a = (e, AST.BlockStmt(b)); pos = fst pos_s } }
(* variable declaration statement *)
  | DIM id = ID AS ty = ID EQ e = expr NEWLINE
    { let (id, _) = id in let (ty, _) = ty in AST.DeclStmt(ty, id, e) }
(* expression statement *)
  | e = expr pos = NEWLINE
    { AST.ExprStmt({ a = Some e; pos }) }

elseif_stmt:
  | pos_s = ELSEIF e = expr THEN NEWLINE b = block elseif = elseif_stmt
    { AST.IfElseStmt{ a = (e, AST.BlockStmt(b), elseif); pos = fst pos_s } }
  | pos_s = ELSEIF e = expr THEN NEWLINE b1 = block ELSE NEWLINE b2 = block ENDIF NEWLINE
    { AST.IfElseStmt{ a = (e, AST.BlockStmt(b1), AST.BlockStmt(b2)); pos = fst pos_s } }
  | pos_s = ELSEIF e = expr THEN NEWLINE b = block ENDIF NEWLINE
    { AST.IfStmt{ a = (e, AST.BlockStmt(b)); pos = fst pos_s } }

arguments:
  | args = separated_list(COMMA, expr) { args }

expr:
  | e = arith_expr { e }
  | id_pos = ID LPAREN args = arguments RPAREN
    { { a = AST.FxnAppExpr({ a = (AST.IdExpr (fst id_pos)); pos = snd id_pos }, args); pos = snd id_pos } }

arith_expr:
  | e = primary_expr { e }
  | e1 = expr pos_s = AND e2 = expr { { a = AST.BinOpExpr(e1, (AST.And, (snd pos_s)), e2); pos = fst pos_s } }
  | e1 = expr pos_s = OR e2 = expr { { a = AST.BinOpExpr(e1, (AST.Or, (snd pos_s)), e2); pos = fst pos_s } }
  | e1 = expr pos_s = DOT e2 = expr { { a = AST.BinOpExpr(e1, (AST.Dot, (snd pos_s)), e2); pos = fst pos_s } }
  | pos_s = NEW e = expr { { a = AST.UnOpExpr((AST.New, (snd pos_s)), e); pos = fst pos_s } }
  | pos_s = NOT e = expr { { a = AST.UnOpExpr((AST.Not, (snd pos_s)), e); pos = fst pos_s } }

primary_expr:
  | id_pos = ID { { a = AST.IdExpr(fst id_pos); pos = snd id_pos } }
  | i_pos = INT { { a = AST.IntExpr(fst i_pos); pos = snd i_pos } }
  | pos_s = TRUE { { a = AST.TrueExpr; pos = fst pos_s } }
  | pos_s = FALSE { { a = AST.FalseExpr; pos = fst pos_s } }
  | pos_s = LEFT { { a = AST.LeftExpr; pos = fst pos_s } }
  | pos_s = RIGHT { { a = AST.RightExpr; pos = fst pos_s } }
  | pos_s = AHEAD { { a = AST.AheadExpr; pos  = fst pos_s } }
  | pos_s = HERE { { a = AST.HereExpr; pos = fst pos_s } }
  | pos_s = NORTH { { a = AST.NorthExpr; pos = fst pos_s } }
  | pos_s = EAST { { a = AST.EastExpr; pos = fst pos_s } }
  | pos_s = SOUTH { { a = AST.SouthExpr; pos  = fst pos_s } }
  | pos_s = WEST { { a = AST.WestExpr; pos = fst pos_s } }
  | LPAREN e = expr RPAREN { e }
