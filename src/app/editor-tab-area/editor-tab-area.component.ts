import { AfterViewInit, Component, EventEmitter, Inject, Input, Output, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material';
import { LOCAL_STORAGE, WebStorageService } from 'angular-webstorage-service';
import { BytecodeInterpreterService, RuntimeError } from '../bytecode-interpreter.service';
import { SelectedLanguage } from '../dashboard/SelectedLanguage';
import { MatrixService } from '../matrix.service';
import { MessageService } from '../message.service';
import { TextEditorComponent } from '../text-editor/text-editor.component';

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

    selectedLanguage = SelectedLanguage.Java;
    selectedEditor: TextEditorComponent = null;
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
                public dialog: MatDialog,
                @Inject(LOCAL_STORAGE) private storage: WebStorageService) {
    }

    ngAfterViewInit() {
        this.selectedEditor = this.mainMethodTextEditor;
    }

    runStepwise(context: CanvasRenderingContext2D) {
        if (this.editorState.reset || this.instructions === null) {
            this.messageService.clear();
            this.messageService.add('Compiling...');
            const jerooCode = this.createJerooCode();
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
            const jerooCode = this.createJerooCode();
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
            } else if (instruction.e === 1) {
                this.extensionMethodsTextEditor.highlightLine(instruction.f);
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
        this.messageService.add(message);
        this.stopState();
    }

    createJerooCode() {
        let jerooCode = '';
        if (this.selectedLanguage === SelectedLanguage.Java) {
            jerooCode += '@Java\n';
        } else if (this.selectedLanguage === SelectedLanguage.Vb) {
            jerooCode += '@VB\n';
        } else if (this.selectedLanguage === SelectedLanguage.Python) {
            jerooCode += '@PYTHON\n';
        } else {
            throw new Error('Unsupported Language');
        }
        jerooCode += this.extensionMethodsTextEditor.getText();
        jerooCode += '\n@@\n';
        jerooCode += this.mainMethodTextEditor.getText();
        return jerooCode;
    }

    undo() {
        this.selectedEditor.undo();
    }

    redo() {
        this.selectedEditor.redo();
    }

    toggleComment() {
        this.selectedEditor.toggleComment();
    }

    indentSelection() {
        this.selectedEditor.indentSelection();
    }

    unindentSelection() {
        this.selectedEditor.unindentSelection();
    }

    formatSelection() {
        this.selectedEditor.formatSelection();
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
        if (index === 0) {
            this.selectedEditor = this.mainMethodTextEditor;
        } else if (index === 1) {
            this.selectedEditor = this.extensionMethodsTextEditor;
        }
    }

    onSelectedLanguageChange() {
        this.mainMethodTextEditor.setMode(this.selectedLanguage);
        this.extensionMethodsTextEditor.setMode(this.selectedLanguage);
        const code = this.createJerooCode();
        this.storage.set(codeCache, code);
        this.markClean();
    }

    getHelpUrl() {
        return `/help/${this.selectedLanguageToString(this.selectedLanguage)}`;
    }

    getTutorialUrl() {
        return `/help/${this.selectedLanguageToString(this.selectedLanguage)}/tutorial`;
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

    private loadCodeFromString(code: string) {
        let mainMethodCodeBuffer = '';
        let extensionMethodCodeBuffer = '';
        let usingExtensionCodeBuffer = false;
        let lookingForHeader = true;

        code.split('\n').forEach(line => {
            if (lookingForHeader && line.startsWith('@')) {
                if (line === '@Java') {
                    this.selectedLanguage = SelectedLanguage.Java;
                } else if (line === '@VB') {
                    this.selectedLanguage = SelectedLanguage.Vb;
                } else if (line === '@PYTHON') {
                    this.selectedLanguage = SelectedLanguage.Python;
                }
                this.mainMethodTextEditor.setMode(this.selectedLanguage);
                this.extensionMethodsTextEditor.setMode(this.selectedLanguage);
                lookingForHeader = false;
                usingExtensionCodeBuffer = true;
            } else if (usingExtensionCodeBuffer && line.startsWith('@@')) {
                usingExtensionCodeBuffer = false;
            } else {
                if (usingExtensionCodeBuffer) {
                    extensionMethodCodeBuffer += line + '\n';
                } else {
                    mainMethodCodeBuffer += line + '\n';
                }
            }
        });

        this.extensionMethodsTextEditor.setText(extensionMethodCodeBuffer.trim());
        this.mainMethodTextEditor.setText(mainMethodCodeBuffer.trim());
    }

    private isClean() {
        return this.mainMethodTextEditor.isClean() && this.extensionMethodsTextEditor.isClean();
    }

    private markClean() {
        this.mainMethodTextEditor.markClean();
        this.extensionMethodsTextEditor.markClean();
    }

    hasCachedCode() {
        return this.storage.get(codeCache) as boolean;
    }

    loadFromCache() {
        const code = this.storage.get(codeCache);
        this.loadCodeFromString(code);
        this.markClean();
    }

    saveToCache() {
        if (!this.isClean()) {
            const code = this.createJerooCode();
            this.storage.set(codeCache, code);
            this.markClean();
        }
    }

    resetCache() {
        this.storage.remove(codeCache);
    }
}
