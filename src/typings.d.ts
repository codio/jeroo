declare interface Instruction {
    op: string;
    a: number;
    b: number;
    c: number;
    d: number;
    e: number;
    f: number;
}

declare interface CompilationResult {
    successful: boolean;
    bytecode?: Instruction[];
    error_message?: string;
}

declare interface JerooCompilerModule {
    compile: (code: string) => CompilationResult;
}

declare var JerooCompiler: JerooCompilerModule;
