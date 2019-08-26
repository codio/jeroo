let map_token = function
  | PythonParser.TRUE (_, s)
  | PythonParser.FALSE (_, s)
  | PythonParser.AND (_, s)
  | PythonParser.OR (_, s)
  | PythonParser.NOT (_, s)
  | PythonParser.EQ (_, s)
  | PythonParser.DEF (_, s)
  | PythonParser.IF (_, s)
  | PythonParser.ELIF (_, s)
  | PythonParser.ELSE (_, s)
  | PythonParser.WHILE (_, s)
  | PythonParser.RIGHT (_, s)
  | PythonParser.LEFT (_, s)
  | PythonParser.AHEAD (_, s)
  | PythonParser.HERE (_, s)
  | PythonParser.NORTH (_, s)
  | PythonParser.SOUTH (_, s)
  | PythonParser.EAST (_, s)
  | PythonParser.WEST (_, s)
  | PythonParser.LPAREN (_, s)
  | PythonParser.RPAREN (_, s)
  | PythonParser.COLON (_, s)
  | PythonParser.COMMA (_, s)
  | PythonParser.SELF (_, s)
  | PythonParser.DOT (_, s)
  | PythonParser.ID (s, _) -> s
  | PythonParser.INT (n, _) -> string_of_int n
  | PythonParser.DEDENT _ -> "de-dentation"
  | PythonParser.INDENT _ -> "new indentation level"
  | PythonParser.NEWLINE _ -> "newline"
  | PythonParser.EOF -> "EOF"
