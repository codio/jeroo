exception LexingException of {
    pos : Position.t;
    exception_type : string;
    message : string
  }

exception CompileException of {
    pos : Position.t;
    pane : Pane.t;
    exception_type : string;
    message : string
  }
