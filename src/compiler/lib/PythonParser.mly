%{
open AST
open Position
%}
%token <int * Position.t> INT
%token <string * Position.t> ID
%token <Position.t * string> TRUE FALSE
%token <Position.t * string> NOT AND OR EQ
%token <Position.t * string> DEF IF ELIF ELSE WHILE SELF
%token <Position.t * string> LPAREN RPAREN
%token <Position.t * string> COLON COMMA DOT
%token <Position.t * string> LEFT RIGHT AHEAD HERE
%token <Position.t * string> NORTH EAST SOUTH WEST
%token <Position.t> INDENT DEDENT NEWLINE
%token EOF

%left OR
%left AND
%right NOT
%left DOT

%start <AST.fxn AST.meta list> fxns
%start <AST.main_fxn AST.meta> main_fxn
%%

main_fxn:
  | stmts = stmt_list EOF
    {
      let pos =
        (Option.bind
          (List.nth_opt stmts 0)
          AST.stmt_pos)
        |> (Option.value ~default:{ lnum = 1; cnum = 0 })
      in
      {
        a = {
          stmts;
        };
        pos
      }
    }

fxns:
  | fxns = newline_or_fxn_list EOF { fxns }

fxn:
  | pos_s = DEF id_pos = ID LPAREN SELF RPAREN COLON stmts = suite
    {
      {
        a = {
          id = fst id_pos;
          stmts;
        };
        pos = fst pos_s
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
  | pos_s = IF e = expr COLON s = suite { AST.IfStmt{ a = (e, AST.BlockStmt(s)); pos = fst pos_s } }
  | pos_s = IF e = expr COLON s1 = suite s2 = else_stmt { AST.IfElseStmt{ a = (e, AST.BlockStmt(s1), s2); pos = fst pos_s } }
  | pos_s = IF e = expr COLON s1 = suite s2 = elseif_stmts { AST.IfElseStmt{ a = (e, AST.BlockStmt(s1), s2); pos = fst pos_s } }

elseif_stmts:
  | pos_s = ELIF e = expr COLON s1 = suite s2 = elseif_stmts { AST.IfElseStmt{ a = (e, AST.BlockStmt(s1), s2); pos = fst pos_s } }
  | pos_s = ELIF e = expr COLON s = suite { AST.IfStmt{ a = (e, AST.BlockStmt(s)); pos = fst pos_s } }
  | pos_s = ELIF e = expr COLON s1 = suite s2 = else_stmt { AST.IfElseStmt{ a = (e, AST.BlockStmt(s1), s2); pos = fst pos_s } }

else_stmt:
  | ELSE COLON s = suite { AST.BlockStmt(s) }

while_stmt:
  | pos_s = WHILE e = expr COLON s = suite { AST.WhileStmt{ a = (e, AST.BlockStmt(s)); pos = fst pos_s } }

simple_stmt:
  | s = expression_stmt { s }
  | s = assignment_stmt { s }

expression_stmt:
  | e = expr pos = NEWLINE { AST.ExprStmt({ a = Some e; pos }) }

assignment_stmt:
  | id_pos = ID pos_s = EQ e = expr NEWLINE { AST.DeclStmt("Jeroo", fst id_pos, { a = AST.UnOpExpr((AST.New, (snd pos_s)), e); pos = snd id_pos }) }

expr:
  | e = arith_expr { e }
  | id_pos = ID LPAREN args = arguments RPAREN { { a = AST.FxnAppExpr({ a = IdExpr (fst id_pos); pos = snd id_pos}, args); pos = snd id_pos } }

arith_expr:
  | e = primary_expr { e }
  | e1 = expr pos_s = AND e2 = expr { { a = AST.BinOpExpr(e1, (AST.And, (snd pos_s)), e2); pos = fst pos_s } }
  | e1 = expr pos_s = OR e2 = expr { { a = AST.BinOpExpr(e1, (AST.Or, (snd pos_s)), e2); pos = fst pos_s } }
  | e1 = expr pos_s = DOT e2 = expr
    {
      match e1.a with
      | AST.IdExpr("self") -> { a = e2.a; pos = fst pos_s }
      | _ ->  { a = AST.BinOpExpr(e1, (AST.Dot, (snd pos_s)), e2); pos = fst pos_s }
    }
  | pos_s = NOT e = expr { { a = AST.UnOpExpr((AST.Not, (snd pos_s)), e); pos = fst pos_s } }

primary_expr:
  | id_pos = ID { { a = AST.IdExpr(fst id_pos); pos  = snd id_pos } }
  | i_pos = INT { { a = AST.IntExpr(fst i_pos); pos = snd i_pos } }
  | pos_s = SELF { { a = AST.IdExpr("self"); pos = fst pos_s } }
  | pos_s = TRUE { { a = AST.TrueExpr; pos = fst pos_s } }
  | pos_s = FALSE { { a = AST.FalseExpr; pos = fst pos_s } }
  | pos_s = LEFT { { a = AST.LeftExpr; pos = fst pos_s } }
  | pos_s = RIGHT { { a = AST.RightExpr; pos = fst pos_s } }
  | pos_s = AHEAD { { a = AST.AheadExpr; pos = fst pos_s } }
  | pos_s = HERE { { a = AST.HereExpr; pos = fst pos_s } }
  | pos_s = NORTH { { a = AST.NorthExpr; pos = fst pos_s } }
  | pos_s = SOUTH { { a = AST.SouthExpr; pos = fst pos_s } }
  | pos_s = EAST { { a = AST.EastExpr; pos = fst pos_s } }
  | pos_s = WEST { { a = AST.WestExpr; pos = fst pos_s } }
  | LPAREN e = expr RPAREN { e }

arguments:
  | args = separated_list(COMMA, expr) { args }
