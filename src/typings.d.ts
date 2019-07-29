declare interface Instruction {
    op: string;
    a: number;
    b: number;
    c: number;
    d: number;
    e: number;
    f: number;
}

declare interface CompilationError {
  pane: number;
  lnum: number;
  cnum: number;
  exceptionType: string;
  message: string;
}

declare interface CompilationResult {
    successful: boolean;
    bytecode?: Instruction[];
    jerooMap?: any[];
    error?: CompilationError;
}

declare interface JerooCompilerModule {
    compile: (code: string) => CompilationResult;
}

declare var JerooCompiler: JerooCompilerModule;
