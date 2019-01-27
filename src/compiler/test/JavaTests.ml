open OUnit2
open Lib

let parse_string s =
  let lexbuf = Lexing.from_string s in
  JavaParser.translation_unit JavaLexer.token lexbuf

let parse_method _test_ctxt =
  let code = "method main() { }" in
  let ast = parse_string code in
  assert_equal ast [("main", [])]

let parse_decl _test_ctxt =
  let code = "method main() { Jeroo j = new Jeroo(1, 2); }" in
  let ast = parse_string code in
  assert_equal ast [("main", [
      `DeclStmt("Jeroo", "j", `UnOpExpr(`New, `FxnAppExpr(`IdExpr("Jeroo"), [`IntExpr(1); `IntExpr(2)])))
    ])]

let parse_if_stmt _test_ctxt =
  let code = "method main() { if (true) { } }" in
  let ast = parse_string code in
  assert_equal ast [("main", [
      `IfStmt(`TrueExpr, `BlockStmt [])
    ])]

let parse_if_else_stmt _test_ctxt =
  let code = "method main() { if (true) { } else { }}" in
  let ast = parse_string code in
  assert_equal ast [("main", [
      `IfElseStmt(`TrueExpr, `BlockStmt([]), `BlockStmt([]))
    ])]

let parse_dangling_if _test_ctxt =
  let code = "method main() { if (true) if (false) {} else { }}" in
  let ast = parse_string code in
  assert_equal ast [("main", [
      `IfStmt(`TrueExpr, `IfElseStmt(`FalseExpr, `BlockStmt([]), `BlockStmt([])))
    ])]

let parse_while_stmt _test_ctxt =
  let code = "method main() { while(true) { }}" in
  let ast = parse_string code in
  assert_equal ast [("main", [
      `WhileStmt(`TrueExpr, `BlockStmt([]))
    ])]

let parse_and _test_ctxt =
  let code = "method main() { if (true && true) { }}" in
  let ast = parse_string code in
  assert_equal ast [("main", [
      `IfStmt(`BinOpExpr(`TrueExpr, `And, `TrueExpr), `BlockStmt([]))
    ])]

let parse_or _test_ctxt =
  let code = "method main() { if (true || true) { }}" in
  let ast = parse_string code in
  assert_equal ast [("main", [
      `IfStmt(`BinOpExpr(`TrueExpr, `Or, `TrueExpr), `BlockStmt([]))
    ])]

let parse_not _test_ctxt =
  let code = "method main() { if (!true) {} }" in
  let ast = parse_string code in
  assert_equal ast [("main", [
      `IfStmt(`UnOpExpr(`Not, `TrueExpr), `BlockStmt([]))
    ])]

let parse_not_precedence _test_ctxt =
  let code = "method main() { if (!true && false) {}}" in
  let ast = parse_string code in
  assert_equal ast [("main", [
      `IfStmt(`BinOpExpr(`UnOpExpr(`Not, `TrueExpr), `And, `FalseExpr), `BlockStmt([]))
    ])]

let parse_paren_precedence _test_ctxt =
  let code = "method main() { if (true && (false && false)) {} }" in
  let ast = parse_string code in
  assert_equal ast [("main"), [
      `IfStmt(`BinOpExpr(`TrueExpr, `And, `BinOpExpr(`FalseExpr, `And, `FalseExpr)), `BlockStmt([]))
    ]]

let parse_comment _test_ctxt =
  let code = "// this is a comment\n method main() { }" in
  let ast = parse_string code in
  assert_equal ast [("main", [])]

let parse_ml_comment _test_ctxt =
  let code = "/* this is a *\n\n\n* multi line comment */method main() {}" in
  let ast = parse_string code in
  assert_equal ast [("main", [])]

let parse_obj_call _test_ctxt =
  let code = "method main() { j.someFxn(1, NORTH);  }" in
  let ast = parse_string code in
  assert_equal ast [("main", [
      `ExprStmt(`BinOpExpr(`IdExpr("j"), `Dot, `FxnAppExpr(`IdExpr("someFxn"), [`IntExpr(1); `NorthExpr])))
    ])]

let suite =
  "Java Parsing">::: [
    "Parse Method">:: parse_method;
    "Parse Decl">:: parse_decl;
    "Parse If Stmt">:: parse_if_stmt;
    "Parse If Else Stmt">:: parse_if_else_stmt;
    "Parse Dangling Else">:: parse_dangling_if;
    "Parse While Stmt">:: parse_while_stmt;
    "Parse And">:: parse_and;
    "Parse Or">:: parse_or;
    "Parse Not">:: parse_not;
    "Parse Not Precedence">:: parse_not_precedence;
    "Parse Paren Precedence">:: parse_paren_precedence;
    "Parse comments">:: parse_comment;
    "Parse ml-comment">:: parse_ml_comment;
    "Parse obj call">:: parse_obj_call;
  ]
