let compile code =
  let ast = Parser.parse code in
  TypeChecker.type_check ast;
  Codegen.codegen ast
