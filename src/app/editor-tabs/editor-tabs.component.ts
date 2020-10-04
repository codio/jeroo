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

import { AfterViewInit, Component, EventEmitter, Inject, Input, Output, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { LOCAL_STORAGE, WebStorageService } from 'ngx-webstorage-service';
import { BytecodeInterpreterService, RuntimeError } from '../bytecode-interpreter/bytecode-interpreter.service';
import { IslandService } from '../island.service';
import { MessageService, LoggingMessage, CompilationErrorMessage, RuntimeErrorMessage } from '../message.service';
import { EditorComponent } from '../editor/editor.component';
import { CodeService, SelectedLanguage, SelectedTab, EditorCode } from '../code.service';
import { Storage } from '../storage';

interface Language {
  value: SelectedLanguage;
  viewValue: string;
}

export interface EditorState {
  reset: boolean;
  executing: boolean;
  paused: boolean;
  stopped: boolean;
}

@Component({
  selector: 'app-editor-tabs',
  templateUrl: './editor-tabs.component.html',
  styleUrls: ['./editor-tabs.component.scss']
})
export class EditorTabsComponent implements AfterViewInit {
  @ViewChild('mainMethodTextEditor', { static: true }) mainMethodEditor: EditorComponent | null = null;
  @ViewChild('extensionMethodsTextEditor', { static: true }) extensionMethodsEditor: EditorComponent | null = null;
  @Input() speed = 225;

  languages: Language[] = [
    { viewValue: 'JAVA/C++/C#', value: SelectedLanguage.Java },
    { viewValue: 'VB.NET', value: SelectedLanguage.Vb },
    { viewValue: 'PYTHON', value: SelectedLanguage.Python }
  ];

  selectedTabIndex = SelectedTab.Main;
  private instructions: Array<Instruction> = [];
  private previousInstruction: Instruction | null = null;

  editorStateValue: EditorState = {
    reset: true,
    executing: false,
    paused: false,
    stopped: false
  };
  @Output()
  editorStateChange = new EventEmitter<EditorState>();
  @Input()
  get editorState() {
    return this.editorStateValue;
  }
  set editorState(val) {
    this.editorStateValue = val;
    this.editorStateChange.emit(this.editorStateValue);
  }

  constructor(private messageService: MessageService,
              private bytecodeService: BytecodeInterpreterService,
              private islandService: IslandService,
              public codeService: CodeService,
              public dialog: MatDialog,
              @Inject(LOCAL_STORAGE) private storage: WebStorageService) {
  }

  ngAfterViewInit() {
    setTimeout(() => {
      const editor = this.getSelectedEditor();
      if (editor) {
        editor.refresh();
        editor.focus();
      }
    });

    this.codeService.getCursorPosition().subscribe((position) => {
      this.selectedTabIndex = position.pane;
      const editor = this.getSelectedEditor();
      editor?.refresh();
      editor?.focus();
      editor?.setCursor({ line: position.lnum - 1, ch: position.cnum });
    });
  }

  runStepwise(context: CanvasRenderingContext2D) {
    if (this.editorState.reset || this.instructions === null) {
      const editorCode = this.getCode();
      if (editorCode) {
        this.messageService.clear();
        this.messageService.addMessage(new LoggingMessage('Compiling...'));
        const jerooCode = this.codeService.genCodeStr(editorCode);
        const result = JerooCompiler.compile(jerooCode);
        if (result.successful && result.bytecode) {
          this.instructions = result.bytecode;
          this.bytecodeService.reset();
          this.bytecodeService.jerooMap = result.jerooMap;
        } else {
          if (result.error !== undefined) {
            this.messageService.addMessage(new CompilationErrorMessage(result.error));
          }
          return;
        }
      }
    }
    this.messageService.addMessage(new LoggingMessage('Stepping...'));
    this.executingState();
    try {
      if (this.mainMethodEditor && this.extensionMethodsEditor) {
        this.mainMethodEditor.setReadOnly(true);
        this.extensionMethodsEditor.setReadOnly(true);
        this.bytecodeService.executeInstructionsUntilLNumChanges(this.instructions, this.islandService);
        this.islandService.render(context);
        if (this.bytecodeService.validInstruction(this.instructions)) {
          this.pauseState();
          this.highlightCurrentLine();
        } else {
          this.cleanupExecution();
        }
      }
    } catch (e) {
      this.islandService.render(context);
      this.handleException(e);
    }
  }

  runContinious(context: CanvasRenderingContext2D) {
    if (this.editorState.reset || this.instructions === null) {
      const editorCode = this.getCode();
      if (editorCode) {
        this.messageService.clear();
        this.messageService.addMessage(new LoggingMessage('Compiling...'));
        const jerooCode = this.codeService.genCodeStr(editorCode);
        const result = JerooCompiler.compile(jerooCode);
        if (result.successful && result.bytecode) {
          this.instructions = result.bytecode;
          this.bytecodeService.reset();
          this.bytecodeService.jerooMap = result.jerooMap;
        } else {
          if (result.error) {
            this.messageService.addMessage(new CompilationErrorMessage(result.error));
          }
          return;
        }
      }
    }
    this.messageService.addMessage(new LoggingMessage('Running resumed...'));
    const executeInstructions = () => {
      try {
        if (this.mainMethodEditor && this.extensionMethodsEditor) {
          this.mainMethodEditor.setReadOnly(true);
          this.extensionMethodsEditor.setReadOnly(true);
          this.bytecodeService.executeInstructionsUntilLNumChanges(this.instructions, this.islandService);
          this.islandService.render(context);
          this.highlightCurrentLine();
          if (this.bytecodeService.validInstruction(this.instructions)) {
            if (!this.editorState.paused && !this.editorState.stopped) {
              setTimeout(executeInstructions, this.speed);
            }
          } else {
            this.cleanupExecution();
          }
        }
      } catch (e) {
        this.islandService.render(context);
        this.handleException(e);
      }
    };
    setTimeout(executeInstructions, this.speed);
    this.executingState();
  }

  private cleanupExecution() {
    if (this.mainMethodEditor != null) {
      this.mainMethodEditor.setReadOnly(false);
      this.extensionMethodsEditor?.setReadOnly(false);
      this.unhighlightPreviousLine();
      this.previousInstruction = null;
      this.messageService.clear();
      this.messageService.addMessage(new LoggingMessage('Program completed'));
      this.stopState();
    }
  }

  private highlightCurrentLine() {
    this.unhighlightPreviousLine();
    if (this.mainMethodEditor && this.extensionMethodsEditor && this.bytecodeService.validInstruction(this.instructions)) {
      const instruction = this.bytecodeService.getCurrentInstruction(this.instructions);
      if (instruction.e === SelectedTab.Main || instruction.op === 'NEW') {
        this.mainMethodEditor.highlightLine(instruction.f);
        this.selectedTabIndex = SelectedTab.Main;
      } else if (instruction.e === SelectedTab.Extensions) {
        this.extensionMethodsEditor.highlightLine(instruction.f);
        this.selectedTabIndex = SelectedTab.Extensions;
      }
      this.previousInstruction = instruction;
    } else {
      this.previousInstruction = null;
    }
  }

  private unhighlightPreviousLine() {
    if (this.previousInstruction && this.mainMethodEditor && this.extensionMethodsEditor) {
      if (this.previousInstruction.e === SelectedTab.Main || this.previousInstruction.op === 'NEW') {
        this.mainMethodEditor.unhighlightLine(this.previousInstruction.f);
      } else if (this.previousInstruction.e === SelectedTab.Extensions) {
        this.extensionMethodsEditor.unhighlightLine(this.previousInstruction.f);
      }
    }
  }

  private handleException(e: any) {
    const runtimeError: RuntimeError = e;
    this.messageService.clear();
    this.unhighlightPreviousLine();
    this.selectedTabIndex = runtimeError.paneNum;
    const editor = this.getSelectedEditor();
    editor?.highlightErrorLine(runtimeError.lineNum);
    this.messageService.addMessage(new RuntimeErrorMessage(runtimeError.message, runtimeError.paneNum, runtimeError.lineNum));
    this.stopState();
  }

  undo() {
    this.getSelectedEditor()?.undo();
  }

  redo() {
    this.getSelectedEditor()?.redo();
  }

  toggleComment() {
    this.getSelectedEditor()?.toggleComment();
  }

  indentSelection() {
    this.getSelectedEditor()?.indentSelection();
  }

  unindentSelection() {
    this.getSelectedEditor()?.unindentSelection();
  }

  format() {
    this.getSelectedEditor()?.format();
  }

  executingState() {
    this.editorState.executing = true;
    this.editorState.reset = false;
    this.editorState.paused = false;
    this.editorState.stopped = false;
  }

  resetState() {
    this.editorState.reset = true;
    this.editorState.executing = false;
    this.editorState.paused = false;
    this.editorState.stopped = false;
    this.messageService.clear();
    this.bytecodeService.reset();
    this.unhighlightPreviousLine();
    this.mainMethodEditor?.setReadOnly(false);
    this.extensionMethodsEditor?.setReadOnly(false);
  }

  pauseState() {
    this.editorState.paused = true;
    this.editorState.executing = false;
    this.editorState.stopped = false;
    this.editorState.reset = false;
  }

  stopState() {
    this.editorState.stopped = true;
    this.editorState.executing = false;
    this.editorState.reset = false;
    this.editorState.paused = false;
  }

  onEditorTabIndexChange(index: number) {
    this.selectedTabIndex = index;
    const selectedEditor = this.getSelectedEditor();
    setTimeout(() => {
      selectedEditor?.refresh();
      selectedEditor?.focus();
    });
  }

  getHelpUrl() {
    return `/help/${this.codeService.selectedLanguage}`;
  }

  getTutorialUrl() {
    return `/help/${this.codeService.selectedLanguage}/tutorial`;
  }

  hasCachedCode() {
    const cachedCode = this.storage.get(Storage.Source) as string;
    const starterJavaCode = '@Java@@';
    const starterVBCode = '@VB@@';
    const starterPythonCode = '@PYTHON@@';
    if (cachedCode) {
      const cachedCodeNoWhitespace = cachedCode.replace(/\s+/, '').trim();
      return !(cachedCodeNoWhitespace === starterJavaCode
        || cachedCodeNoWhitespace === starterVBCode
        || cachedCodeNoWhitespace === starterPythonCode);
    } else {
      return false;
    }
  }

  hasCachedConfig() {
    const cachedConfigs = this.storage.get(Storage.Preferences);
    return cachedConfigs as boolean;
  }

  loadCodeFromCache() {
    const code = this.storage.get(Storage.Source);
    this.loadCode(code);
  }

  loadCode(codeStr: string) {
    const editorCode = this.codeService.parseCodeFromStr(codeStr);
    if (this.mainMethodEditor && this.extensionMethodsEditor) {
      this.mainMethodEditor.setText(editorCode.mainMethodCode);
      this.extensionMethodsEditor.setText(editorCode.extensionsMethodCode);
    }
  }

  loadPreferencesFromCache() {
    const config = this.storage.get(Storage.Preferences);
    this.codeService.prefrences = config;
  }

  getCode(): EditorCode | null {
    if (this.mainMethodEditor && this.extensionMethodsEditor) {
      return {
        extensionsMethodCode: this.extensionMethodsEditor.getText(),
        mainMethodCode: this.mainMethodEditor.getText()
      };
    } else {
      return null;
    }
  }

  saveToLocal() {
    const editorCode = this.getCode();
    if (editorCode) {
      const codeStr = this.codeService.genCodeStr(editorCode);
      this.storage.set(Storage.Source, codeStr);
    }
  }

  resetCache() {
    this.storage.remove(Storage.Source);
  }

  resetPreferences() {
    this.storage.remove(Storage.Preferences);
  }

  private getSelectedEditor() {
    if (this.selectedTabIndex === SelectedTab.Main) {
      return this.mainMethodEditor;
    } else if (this.selectedTabIndex === SelectedTab.Extensions) {
      return this.extensionMethodsEditor;
    } else {
      return null;
    }
  }

  clearCode() {
    if (!this.mainMethodEditor?.isReadOnly() && !this.extensionMethodsEditor?.isReadOnly()) {
      this.mainMethodEditor?.setText('');
      this.extensionMethodsEditor?.setText('');
      this.resetCache();
    }
  }
}
