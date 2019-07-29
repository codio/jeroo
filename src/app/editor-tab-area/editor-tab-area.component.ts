import { AfterViewInit, Component, EventEmitter, Inject, Input, Output, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { LOCAL_STORAGE, WebStorageService } from 'angular-webstorage-service';
import { BytecodeInterpreterService, RuntimeError } from '../bytecode-interpreter.service';
import { MatrixService } from '../matrix.service';
import { MessageService } from '../message.service';
import { TextEditorComponent } from '../text-editor/text-editor.component';
import { CodeService, SelectedLanguage, SelectedTab } from '../code.service';
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
  selector: 'app-editor-tab-area',
  templateUrl: './editor-tab-area.component.html',
  styleUrls: ['./editor-tab-area.component.scss']
})
export class EditorTabAreaComponent implements AfterViewInit {
  @ViewChild('mainMethodTextEditor', { static: true }) mainMethodTextEditor: TextEditorComponent;
  @ViewChild('extensionMethodsTextEditor', { static: true }) extensionMethodsTextEditor: TextEditorComponent;
  @Input() speed: number;

  languages: Language[] = [
    { viewValue: 'JAVA/C++/C#', value: SelectedLanguage.Java },
    { viewValue: 'VB.NET', value: SelectedLanguage.Vb },
    { viewValue: 'PYTHON', value: SelectedLanguage.Python }
  ];

  selectedTabIndex = SelectedTab.Main;
  private instructions: Array<Instruction> = null;
  private previousInstruction: Instruction = null;

  editorStateValue: EditorState;
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
              private matrixService: MatrixService,
              public codeService: CodeService,
              public dialog: MatDialog,
              @Inject(LOCAL_STORAGE) private storage: WebStorageService) {
  }

  ngAfterViewInit() {
    setTimeout(() => {
      this.getSelectedEditor().refresh();
      this.getSelectedEditor().focus();
    });

    this.codeService.getCursorPosition().subscribe((position) => {
      this.selectedTabIndex = position.pane;
      const editor = this.getSelectedEditor();
      editor.refresh();
      editor.focus();
      editor.setCursor({ line: position.lnum - 1, ch: position.cnum });
    });
  }

  runStepwise(context: CanvasRenderingContext2D) {
    if (this.editorState.reset || this.instructions === null) {
      this.messageService.clear();
      this.messageService.addErrorMessage('Compiling...');
      const jerooCode = this.codeService.genCodeStr();
      const result = JerooCompiler.compile(jerooCode);
      if (result.successful) {
        this.instructions = result.bytecode;
        this.bytecodeService.reset();
        this.bytecodeService.jerooMap = result.jerooMap;
      } else {
        this.messageService.addCompilationError(result.error);
        return;
      }
    }
    this.messageService.addErrorMessage('Stepping...');
    this.executingState();
    try {
      this.mainMethodTextEditor.setReadOnly(true);
      this.extensionMethodsTextEditor.setReadOnly(true);
      this.bytecodeService.executeInstructionsUntilLNumChanges(this.instructions, this.matrixService);
      this.matrixService.render(context);
      if (this.bytecodeService.validInstruction(this.instructions)) {
        this.pauseState();
        this.highlightCurrentLine();
      } else {
        this.cleanupExecution();
      }
    } catch (e) {
      this.matrixService.render(context);
      this.handleException(e);
    }
  }

  runContinious(context: CanvasRenderingContext2D) {
    if (this.editorState.reset || this.instructions === null) {
      this.messageService.clear();
      this.messageService.addErrorMessage('Compiling...');
      const jerooCode = this.codeService.genCodeStr();
      const result = JerooCompiler.compile(jerooCode);
      if (result.successful) {
        this.instructions = result.bytecode;
        this.bytecodeService.reset();
        this.bytecodeService.jerooMap = result.jerooMap;
      } else {
        this.messageService.addCompilationError(result.error);
        return;
      }
    }
    this.messageService.addErrorMessage('Running resumed...');
    const executeInstructions = () => {
      try {
        this.mainMethodTextEditor.setReadOnly(true);
        this.extensionMethodsTextEditor.setReadOnly(true);
        this.bytecodeService.executeInstructionsUntilLNumChanges(this.instructions, this.matrixService);
        this.matrixService.render(context);
        this.highlightCurrentLine();
        if (this.bytecodeService.validInstruction(this.instructions)) {
          if (!this.editorState.paused && !this.editorState.stopped) {
            setTimeout(executeInstructions, this.speed);
          }
        } else {
          this.cleanupExecution();
        }
      } catch (e) {
        this.matrixService.render(context);
        this.handleException(e);
      }
    };
    setTimeout(executeInstructions, this.speed);
    this.executingState();
  }

  private cleanupExecution() {
    this.mainMethodTextEditor.setReadOnly(false);
    this.extensionMethodsTextEditor.setReadOnly(false);
    this.unhighlightPreviousLine();
    this.previousInstruction = null;
    this.messageService.clear();
    this.messageService.addErrorMessage('Program completed');
    this.stopState();
  }

  private highlightCurrentLine() {
    this.unhighlightPreviousLine();
    if (this.bytecodeService.validInstruction(this.instructions)) {
      const instruction = this.bytecodeService.getCurrentInstruction(this.instructions);
      if (instruction.e === SelectedTab.Main || instruction.op === 'NEW') {
        this.mainMethodTextEditor.highlightLine(instruction.f);
        this.selectedTabIndex = SelectedTab.Main;
      } else if (instruction.e === SelectedTab.Extensions) {
        this.extensionMethodsTextEditor.highlightLine(instruction.f);
        this.selectedTabIndex = SelectedTab.Extensions;
      }
      this.previousInstruction = instruction;
    } else {
      this.previousInstruction = null;
    }
  }

  private unhighlightPreviousLine() {
    if (this.previousInstruction !== null) {
      if (this.previousInstruction.e === SelectedTab.Main || this.previousInstruction.op === 'NEW') {
        this.mainMethodTextEditor.unhighlightLine(this.previousInstruction.f);
      } else if (this.previousInstruction.e === SelectedTab.Extensions) {
        this.extensionMethodsTextEditor.unhighlightLine(this.previousInstruction.f);
      }
    }
  }

  private handleException(e: any) {
    const runtimeError: RuntimeError = e;
    this.messageService.clear();
    const message = `Runtime error line ${runtimeError.line_num}: ${runtimeError.message}`;
    this.unhighlightPreviousLine();
    this.selectedTabIndex = runtimeError.pane_num;
    this.getSelectedEditor().highlightErrorLine(runtimeError.line_num);
    this.messageService.addErrorMessage(message);
    this.stopState();
  }

  undo() {
    this.getSelectedEditor().undo();
  }

  redo() {
    this.getSelectedEditor().redo();
  }

  toggleComment() {
    this.getSelectedEditor().toggleComment();
  }

  indentSelection() {
    this.getSelectedEditor().indentSelection();
  }

  unindentSelection() {
    this.getSelectedEditor().unindentSelection();
  }

  formatSelection() {
    this.getSelectedEditor().formatSelection();
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
    this.mainMethodTextEditor.setReadOnly(false);
    this.extensionMethodsTextEditor.setReadOnly(false);
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
      selectedEditor.refresh();
      selectedEditor.focus();
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
    this.codeService.loadCodeFromStr(code);
  }

  loadPreferencesFromCache() {
    const config = this.storage.get(Storage.Preferences);
    this.codeService.prefrences = config;
  }

  saveToLocal() {
    const code = this.codeService.genCodeStr();
    this.storage.set(Storage.Source, code);
  }

  resetCache() {
    this.storage.remove(Storage.Source);
  }

  resetPreferences() {
    this.storage.remove(Storage.Preferences);
  }

  private getSelectedEditor() {
    if (this.selectedTabIndex === SelectedTab.Main) {
      return this.mainMethodTextEditor;
    } else if (this.selectedTabIndex === SelectedTab.Extensions) {
      return this.extensionMethodsTextEditor;
    } else {
      return null;
    }
  }

  clearCode() {
    if (!this.mainMethodTextEditor.isReadOnly() && !this.extensionMethodsTextEditor.isReadOnly())  {
      this.mainMethodTextEditor.setText('');
      this.extensionMethodsTextEditor.setText('');
      this.resetCache();
    }
  }
}
