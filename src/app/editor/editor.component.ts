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

import { Component, ViewChild, ElementRef, AfterViewInit, Output, EventEmitter, Input } from '@angular/core';
import { CodemirrorService } from '../codemirror/codemirror.service';
import { SelectedLanguage, EditorPreferences, Themes } from '../code.service';

@Component({
  selector: 'app-editor',
  templateUrl: './editor.component.html'
})
export class EditorComponent implements AfterViewInit {
  @ViewChild('editorTextarea', { static: true }) editorTextArea: ElementRef | null = null;
  private editor: CodeMirror.Editor | null = null;

  @Output()
  codeChange = new EventEmitter<string>();

  private preferencesVal: EditorPreferences = {
    fontSize: 12,
    colorTheme: Themes.Default
  };
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

  private langVal: SelectedLanguage = SelectedLanguage.Java;
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
    const editorTextArea = this.editorTextArea?.nativeElement as HTMLTextAreaElement;
    this.editor = this.codemirrorService.getCodemirror().fromTextArea(editorTextArea, {
      mode: 'jeroo-java',
      theme: 'default',
      lineNumbers: true,
      extraKeys: {
        Tab: 'defaultTab',
        'Shift-Tab': 'indentLess',
        'Shift-Ctrl-F': (editor) => (editor as any).autoIndentAll(),
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
      this.editor?.setOption('mode', 'jeroo-java');
      this.editor?.setOption('autoCloseBrackets', '{}()');
    } else if (language === SelectedLanguage.Vb) {
      this.editor?.setOption('mode', 'jeroo-vb');
      this.editor?.setOption('autoCloseBrackets', '()');
    } else if (language === SelectedLanguage.Python) {
      this.editor?.setOption('mode', 'jeroo-python');
      this.editor?.setOption('autoCloseBrackets', '()');
    }
  }

  getText() {
    if (this.editor) {
      return this.editor.getValue();
    } else {
      return '';
    }
  }

  setText(incomingString: string) {
    this.editor?.setValue(incomingString);
  }

  undo() {
    this.editor?.undo();
  }

  redo() {
    this.editor?.redo();
  }

  toggleComment() {
    this.editor?.toggleComment();
  }

  indentSelection() {
    this.editor?.execCommand('defaultTab');
  }

  unindentSelection() {
    this.editor?.execCommand('indentLess');
  }

  format() {
    (this.editor as any)?.autoIndentAll();
  }

  highlightLine(lineNum: number) {
    const line = this.editor?.getLineHandle(lineNum - 1);
    if (line) {
      this.editor?.addLineClass(line, 'background', 'activeline-highlight');
    }
  }

  highlightErrorLine(lineNum: number) {
    const line = this.editor?.getLineHandle(lineNum - 1);
    if (line) {
      this.editor?.addLineClass(line, 'background', 'errorline-highlight');
    }
  }

  unhighlightLine(lineNum: number) {
    const line = this.editor?.getLineHandle(lineNum - 1);
    if (line) {
      this.editor?.removeLineClass(line, 'background', 'activeline-highlight');
      this.editor?.removeLineClass(line, 'background', 'errorline-highlight');
    }
  }

  isReadOnly() {
    if (this.editor) {
      return this.editor.getOption('readOnly') as boolean;
    } else {
      return false;
    }
  }

  setReadOnly(readOnly: boolean) {
    this.editor?.setOption('readOnly', readOnly);
  }

  refresh() {
    this.editor?.refresh();
  }

  focus() {
    this.editor?.focus();
  }

  getCursor() {
    return this.editor?.getCursor();
  }

  setCursor(newPosition: CodeMirror.Position) {
    return this.editor?.setCursor(newPosition);
  }
}
