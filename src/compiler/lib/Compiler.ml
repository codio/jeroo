let compile code =
  let ast = Parser.parse code in
  TypeChecker.typecheck ast;
  Codegen.codegen ast
