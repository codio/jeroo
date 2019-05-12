import { AfterViewInit, Component, EventEmitter, Inject, Input, Output, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material';
import { LOCAL_STORAGE, WebStorageService } from 'angular-webstorage-service';
import { BytecodeInterpreterService, RuntimeError } from '../bytecode-interpreter.service';
import { MatrixService } from '../matrix.service';
import { MessageService } from '../message.service';
import { TextEditorComponent } from '../text-editor/text-editor.component';
import { CodeService, SelectedLanguage } from '../code.service';

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

const codeCache = 'source';

@Component({
    selector: 'app-editor-tab-area',
    templateUrl: './editor-tab-area.component.html',
    styleUrls: ['./editor-tab-area.component.scss']
})
export class EditorTabAreaComponent implements AfterViewInit {
    @ViewChild('mainMethodTextEditor') mainMethodTextEditor: TextEditorComponent;
    @ViewChild('extensionMethodsTextEditor') extensionMethodsTextEditor: TextEditorComponent;
    @Input() speed: number;

    languages: Language[] = [
        { viewValue: 'JAVA/C++/C#', value: SelectedLanguage.Java },
        { viewValue: 'VB.NET', value: SelectedLanguage.Vb },
        { viewValue: 'PYTHON', value: SelectedLanguage.Python }
    ];

    selectedTabIndex = 0;
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
    }

    runStepwise(context: CanvasRenderingContext2D) {
        if (this.editorState.reset || this.instructions === null) {
            this.messageService.clear();
            this.messageService.add('Compiling...');
            const jerooCode = this.codeService.genCodeStr();
            const result = JerooCompiler.compile(jerooCode);
            if (result.successful) {
                this.instructions = result.bytecode;
                this.bytecodeService.reset();
                this.bytecodeService.jerooMap = result.jerooMap;
            } else {
                this.messageService.add(result.error);
                return;
            }
        }
        this.messageService.add('Stepping...');
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
            this.messageService.add('Compiling...');
            const jerooCode = this.codeService.genCodeStr();
            const result = JerooCompiler.compile(jerooCode);
            if (result.successful) {
                this.instructions = result.bytecode;
                this.bytecodeService.reset();
                this.bytecodeService.jerooMap = result.jerooMap;
            } else {
                this.messageService.add(result.error);
                return;
            }
        }
        this.messageService.add('Running resumed...');
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
        this.messageService.add('Program completed');
        this.stopState();
    }

    private highlightCurrentLine() {
        this.unhighlightPreviousLine();
        if (this.bytecodeService.validInstruction(this.instructions)) {
            const instruction = this.bytecodeService.getCurrentInstruction(this.instructions);
            if (instruction.e === 0 || instruction.op === 'NEW') {
                this.mainMethodTextEditor.highlightLine(instruction.f);
                this.selectedTabIndex = 0;
            } else if (instruction.e === 1) {
                this.extensionMethodsTextEditor.highlightLine(instruction.f);
                this.selectedTabIndex = 1;
            }
            this.previousInstruction = instruction;
        } else {
            this.previousInstruction = null;
        }
    }

    private unhighlightPreviousLine() {
        if (this.previousInstruction !== null) {
            if (this.previousInstruction.e === 0 || this.previousInstruction.op === 'NEW') {
                this.mainMethodTextEditor.unhighlightLine(this.previousInstruction.f);
            } else if (this.previousInstruction.e === 1) {
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
        this.messageService.add(message);
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
        return `/help/${this.selectedLanguageToString(this.codeService.selectedLanguage)}`;
    }

    getTutorialUrl() {
        return `/help/${this.selectedLanguageToString(this.codeService.selectedLanguage)}/tutorial`;
    }

    private selectedLanguageToString(lang: SelectedLanguage) {
        if (lang === SelectedLanguage.Java) {
            return 'java';
        } else if (lang === SelectedLanguage.Vb) {
            return 'vb';
        } else if (lang === SelectedLanguage.Python) {
            return 'python';
        } else {
            throw new Error('Invalid Language');
        }
    }

    hasCachedCode() {
        const cachedCode = this.storage.get(codeCache) as string;
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

    loadFromCache() {
        const code = this.storage.get(codeCache);
        this.codeService.loadCodeFromStr(code);
    }

    saveToLocal() {
        const code = this.codeService.genCodeStr();
        this.storage.set(codeCache, code);
    }

    resetCache() {
        this.storage.remove(codeCache);
    }

    private getSelectedEditor() {
        if (this.selectedTabIndex === 0) {
            return this.mainMethodTextEditor;
        } else if (this.selectedTabIndex === 1) {
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
