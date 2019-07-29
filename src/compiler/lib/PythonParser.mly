%{
open AST
%}
%token <int * Position.t> INT
%token <string * Position.t> ID
%token <Position.t> TRUE FALSE
%token <Position.t> NOT AND OR EQ
%token <Position.t> DEF IF ELIF ELSE WHILE SELF NEWLINE
%token <Position.t> LPAREN RPAREN
%token <Position.t> INDENT DEDENT
%token <Position.t> COLON COMMA DOT
%token <Position.t> LEFT RIGHT AHEAD HERE
%token <Position.t> NORTH EAST SOUTH WEST
%token <Position.t> EOF

%left OR
%left AND
%right NOT
%left DOT

%start <AST.fxn list> fxns
%start <AST.fxn> main_fxn
%%

main_fxn:
  | stmts = stmt_list end_pos = EOF
    {
      {
        id = "main";
        stmts;
        start_lnum = 1; (* TODO *)
        end_lnum = succ end_pos.lnum
      }
    }

fxns:
  | fxns = newline_or_fxn_list EOF { fxns }

fxn:
  | start_pos = DEF id_pos = ID LPAREN SELF RPAREN COLON stmts = suite
    {
      {
        id = fst id_pos;
        stmts;
        start_lnum = start_pos.lnum;
        end_lnum = 1 (* TODO *)
      }
    }

stmt_list:
  | NEWLINE stmts = stmt_list { stmts }
  | s = stmt stmts = stmt_list { s :: stmts }
  | { [] }

newline_or_fxn_list:
  | NEWLINE fxns = newline_or_fxn_list { fxns }
  | fxn = fxn fxns = newline_or_fxn_list { fxn :: fxns }
  | { [] }

compound_stmt:
  | s = if_stmt { s }
  | s = while_stmt { s }

stmt:
  | s = simple_stmt { AST.BlockStmt([s]) }
  | s = compound_stmt { s }

suite:
  | stmts = simple_stmt { [stmts] }
  | NEWLINE INDENT stmts = stmt+ DEDENT { stmts }

if_stmt:
  | pos = IF e = expr COLON s = suite { AST.IfStmt{ a = (e, AST.BlockStmt(s)); pos } }
  | pos = IF e = expr COLON s1 = suite s2 = else_stmt { AST.IfElseStmt{ a = (e, AST.BlockStmt(s1), s2); pos } }
  | pos = IF e = expr COLON s1 = suite s2 = elseif_stmts { AST.IfElseStmt{ a = (e, AST.BlockStmt(s1), s2); pos } }

elseif_stmts:
  | pos = ELIF e = expr COLON s1 = suite s2 = elseif_stmts { AST.IfElseStmt{ a = (e, AST.BlockStmt(s1), s2); pos } }
  | pos = ELIF e = expr COLON s = suite { AST.IfStmt{ a = (e, AST.BlockStmt(s)); pos } }
  | pos = ELIF e = expr COLON s1 = suite s2 = else_stmt { AST.IfElseStmt{ a = (e, AST.BlockStmt(s1), s2); pos } }

else_stmt:
  | ELSE COLON s = suite { AST.BlockStmt(s) }

while_stmt:
  | pos = WHILE e = expr COLON s = suite { AST.WhileStmt{ a = (e, AST.BlockStmt(s)); pos } }

simple_stmt:
  | s = expression_stmt { s }
  | s = assignment_stmt { s }

expression_stmt:
  | e = expr pos = NEWLINE { AST.ExprStmt({ a = Some e; pos }) }

assignment_stmt:
  | id_pos = ID EQ e = expr NEWLINE { AST.DeclStmt("Jeroo", fst id_pos, { a = AST.UnOpExpr(AST.New, e); pos = snd id_pos }) }

expr:
  | e = arith_expr { e }
  | id_pos = ID LPAREN args = arguments RPAREN { { a = AST.FxnAppExpr({ a = IdExpr (fst id_pos); pos = snd id_pos}, args); pos = snd id_pos } }

arith_expr:
  | e = primary_expr { e }
  | e1 = expr pos = AND e2 = expr { { a = AST.BinOpExpr(e1, AST.And, e2); pos } }
  | e1 = expr pos = OR e2 = expr { { a = AST.BinOpExpr(e1, AST.Or, e2); pos } }
  | e1 = expr pos = DOT e2 = expr
    {
      match e1.a with
      | AST.IdExpr("self") -> { a = e2.a; pos }
      | _ ->  { a = AST.BinOpExpr(e1, AST.Dot, e2); pos }
    }
  | pos = NOT e = expr { { a = AST.UnOpExpr(AST.Not, e); pos } }

primary_expr:
  | id_pos = ID { { a = AST.IdExpr(fst id_pos); pos  = snd id_pos } }
  | i_pos = INT { { a = AST.IntExpr(fst i_pos); pos = snd i_pos } }
  | pos = SELF { { a = AST.IdExpr("self"); pos  } }
  | pos = TRUE { { a = AST.TrueExpr; pos } }
  | pos = FALSE { { a = AST.FalseExpr; pos } }
  | pos = LEFT { { a = AST.LeftExpr; pos } }
  | pos = RIGHT { { a = AST.RightExpr; pos } }
  | pos = AHEAD { { a = AST.AheadExpr; pos } }
  | pos = HERE { { a = AST.HereExpr; pos } }
  | pos = NORTH { { a = AST.NorthExpr; pos } }
  | pos = SOUTH { { a = AST.SouthExpr; pos } }
  | pos = EAST { { a = AST.EastExpr; pos } }
  | pos = WEST { { a = AST.WestExpr; pos } }
  | LPAREN e = expr RPAREN { e }

arguments:
  | args = separated_list(COMMA, expr) { args }
