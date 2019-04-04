import { Component, ViewChild, ElementRef, AfterViewInit } from '@angular/core';
import { SelectedLanguage } from '../dashboard/SelectedLanguage';
import { CodemirrorService } from '../codemirror.service';

@Component({
    selector: 'app-text-editor',
    templateUrl: './text-editor.component.html'
})
export class TextEditorComponent implements AfterViewInit {
    @ViewChild('editorTextarea') editorTextArea: ElementRef;
    private editor: CodeMirror.Editor = null;

    constructor(private codemirrorService: CodemirrorService) { }

    ngAfterViewInit() {
        const editorTextArea = this.editorTextArea.nativeElement as HTMLTextAreaElement;
        this.editor = this.codemirrorService.getCodemirror().fromTextArea(editorTextArea, {
            mode: 'jeroo-java',
            theme: 'default',
            lineNumbers: true,
            extraKeys: {
                'Tab': 'defaultTab',
                'Shift-Tab': 'indentLess',
                'Shift-Ctrl-F': 'indentAuto',
                'Ctrl-/': 'toggleComment',
                'Ctrl-z': 'undo',
                'Shift-Ctrl-Z': 'redo'
            }
        });
        this.editor.setOption('matchBrackets', true);
        this.editor.setOption('autoCloseBrackets', '{}()');
        this.editor.setSize(null, 500);
        this.editor.refresh();
    }

    setMode(language: SelectedLanguage) {
        if (language === SelectedLanguage.Java) {
            this.editor.setOption('mode', 'jeroo-java');
            this.editor.setOption('autoCloseBrackets', '{}()');
        } else if (language === SelectedLanguage.Vb) {
            this.editor.setOption('mode', 'jeroo-vb');
            this.editor.setOption('autoCloseBrackets', '()');
        } else if (language === SelectedLanguage.Python) {
            this.editor.setOption('mode', 'jeroo-python');
            this.editor.setOption('autoCloseBrackets', '()');
        }
    }

    getText() {
        return this.editor.getValue();
    }

    undo() {
        this.editor.execCommand('undo');
    }

    redo() {
        this.editor.execCommand('redo');
    }

    toggleComment() {
        this.editor.execCommand('toggleComment');
    }

    indentSelection() {
        this.editor.execCommand('defaultTab');
    }

    unindentSelection() {
        this.editor.execCommand('indentLess');
    }

    formatSelection() {
        this.editor.execCommand('indentAuto');
    }

    highlightLine(lineNum: number) {
        const line = this.editor.getDoc().getLineHandle(lineNum - 1);
        this.editor.addLineClass(line, 'background', 'CodeMirror-activeline-background');
    }

    unhighlightLine(lineNum: number) {
        const line = this.editor.getDoc().getLineHandle(lineNum - 1);
        this.editor.removeLineClass(line, 'background', 'CodeMirror-activeline-background');
    }

    setReadOnly(readOnly: boolean) {
        this.editor.setOption('readOnly', readOnly);
    }
}
