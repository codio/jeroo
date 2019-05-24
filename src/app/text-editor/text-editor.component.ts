import { Component, ViewChild, ElementRef, AfterViewInit, Output, EventEmitter, Input } from '@angular/core';
import { CodemirrorService } from '../codemirror/codemirror.service';
import { SelectedLanguage, EditorPreferences } from '../code.service';

@Component({
  selector: 'app-text-editor',
  templateUrl: './text-editor.component.html'
})
export class TextEditorComponent implements AfterViewInit {
  @ViewChild('editorTextarea') editorTextArea: ElementRef;
  private editor: CodeMirror.Editor = null;

  @Output()
  codeChange = new EventEmitter<string>();
  @Input()
  get code() {
    if (this.editor) {
      return this.editor.getValue();
    }
  }
  set code(val) {
    if (this.editor) {
      const cursor = (this.editor as any).getCursor();
      this.editor.setValue(val);
      (this.editor as any).setCursor(cursor);
      this.codeChange.emit(this.editor.getValue());
    }
  }

  private preferencesVal: EditorPreferences;
  @Input()
  get preferences() {
    return this.preferencesVal;
  }
  set preferences(val) {
    this.preferencesVal = val;
    if (this.editor) {
      this.editor.setOption('theme', this.preferencesVal.colorTheme);
      this.editor.getWrapperElement().style.fontSize = `${this.preferencesVal.fontSize}px`;
      this.editor.refresh();
    }
  }

  private langVal: SelectedLanguage;
  @Input()
  get lang() {
    return this.langVal;
  }
  set lang(val) {
    this.langVal = val;
    if (this.editor) {
      this.setMode(this.langVal);
    }
  }

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
    this.editor.setOption('theme', this.preferences.colorTheme);
    this.editor.getWrapperElement().style.fontSize = `${this.preferences.fontSize}px`;
    this.editor.setSize(null, 500);
    this.editor.refresh();

    this.editor.on('change', (editor) => {
      this.codeChange.emit(editor.getValue());
    });
  }

  private setMode(language: SelectedLanguage) {
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
    return this.code;
  }

  setText(incomingString: string) {
    this.editor.setValue(incomingString);
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
    const totalLines = (this.editor as any).lineCount();
    (this.editor as any).autoFormatRange({line: 0, ch: 0}, {line: totalLines});
  }

  highlightLine(lineNum: number) {
    const line = this.editor.getDoc().getLineHandle(lineNum - 1);
    if (line) {
      this.editor.addLineClass(line, 'background', 'activeline-highlight');
    }
  }

  highlightErrorLine(lineNum: number) {
    const line = this.editor.getDoc().getLineHandle(lineNum - 1);
    if (line) {
      this.editor.addLineClass(line, 'background', 'errorline-highlight');
    }
  }

  unhighlightLine(lineNum: number) {
    const line = this.editor.getDoc().getLineHandle(lineNum - 1);
    if (line) {
      this.editor.removeLineClass(line, 'background', 'activeline-highlight');
      this.editor.removeLineClass(line, 'background', 'errorline-highlight');
    }
  }

  isReadOnly() {
    return this.editor.getOption('readOnly') as boolean;
  }

  setReadOnly(readOnly: boolean) {
    this.editor.setOption('readOnly', readOnly);
  }

  refresh() {
    this.editor.refresh();
  }

  focus() {
    this.editor.focus();
  }
}
