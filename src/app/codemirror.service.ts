import { Injectable } from '@angular/core';
import 'codemirror/lib/codemirror';
import 'codemirror/addon/mode/simple';
import 'codemirror/addon/edit/matchbrackets';
import 'codemirror/addon/edit/closebrackets';
import 'codemirror/addon/comment/comment';
import { javaMode } from './text-editor/javaMode';
import { VBMode } from './text-editor/VBMode';
import { pythonMode } from './text-editor/pythonMode';
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
    }

    getCodemirror() {
        return CodeMirror;
    }
}
