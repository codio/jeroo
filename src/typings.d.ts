/* **********************************************************************
Jeroo is a programming language learning tool for students and teachers.
Copyright (C) <2019>  <Benjamin Konz>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
********************************************************************** */

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
