import { Injectable } from '@angular/core';
import 'codemirror/lib/codemirror';
import 'codemirror/addon/mode/simple';
import 'codemirror/addon/edit/matchbrackets';
import 'codemirror/addon/edit/closebrackets';
import 'codemirror/addon/comment/comment';
import { javaMode } from './javaMode';
import { VBMode } from './VBMode';
import { pythonMode } from './pythonMode';
import * as CodeMirror from 'codemirror';

@Injectable({
    providedIn: 'root'
})
export class CodemirrorService {

    constructor() {
        (CodeMirror as any).defineSimpleMode('jeroo-java', javaMode);
        (CodeMirror as any).defineSimpleMode('jeroo-vb', VBMode);
        (CodeMirror as any).defineSimpleMode('jeroo-python', pythonMode);
        (CodeMirror as any).commands['toggleComment'] = (editor: CodeMirror.Editor) => (editor as any).toggleComment();
        (CodeMirror as any).commands['undo'] = (editor: CodeMirror.Editor) => editor.getDoc().undo();
        (CodeMirror as any).commands['redo'] = (editor: CodeMirror.Editor) => editor.getDoc().redo();
        CodeMirror.defineExtension('autoFormatRange', function (from: CodeMirror.Position, to: CodeMirror.Position) {
            const cm = this;
            const outer = cm.getMode(), text = cm.getRange(from, to).split('\n');
            const state = (CodeMirror as any).copyState(outer, cm.getTokenAt(from).state);
            const tabSize = cm.getOption('tabSize');

            let out = '', lines = 0, atSol = from.ch === 0;
            function newline() {
                out += '\n';
                atSol = true;
                ++lines;
            }

            for (let i = 0; i < text.length; ++i) {
                const stream = new (CodeMirror as any).StringStream(text[i], tabSize);
                while (!stream.eol()) {
                    const inner = CodeMirror.innerMode(outer, state);
                    const style = outer.token(stream, state), cur = stream.current();
                    stream.start = stream.pos;
                    if (!atSol || /\S/.test(cur)) {
                        out += cur;
                        atSol = false;
                    }
                    if (!atSol && (inner.mode as any).newlineAfterToken &&
                        (inner.mode as any).newlineAfterToken(style, cur, stream.string.slice(stream.pos)
                                                              || text[i + 1]
                                                              || '', inner.state)) {
                        newline();
                    }
                }
                if (!stream.pos && outer.blankLine) {
                    outer.blankLine(state);
                }
                if (!atSol) {
                    newline();
                }
            }

            cm.operation(function () {
                cm.replaceRange(out, from, to);
                for (let cur = from.line + 1, end = from.line + lines; cur <= end; ++cur) {
                    cm.indentLine(cur, 'smart');
                }
            });
        });

        // Applies automatic mode-aware indentation to the specified range
        CodeMirror.defineExtension('autoIndentRange', function (from: CodeMirror.Position, to: CodeMirror.Position) {
            const cmInstance = this;
            this.operation(function () {
                for (let i = from.line; i <= to.line; i++) {
                    cmInstance.indentLine(i, 'smart');
                }
            });
        });
    }

    getCodemirror() {
        return CodeMirror;
    }
}
