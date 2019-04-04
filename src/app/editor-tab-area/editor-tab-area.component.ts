import { Component, ViewChild, AfterViewInit, Output, Input, EventEmitter } from '@angular/core';
import { SelectedLanguage } from '../dashboard/SelectedLanguage';
import { TextEditorComponent } from '../text-editor/text-editor.component';
import { RuntimeError, BytecodeInterpreterService } from '../bytecode-interpreter.service';
import { MessageService } from '../message.service';
import { MatrixService } from '../matrix.service';

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
    templateUrl: './editor-tab-area.component.html'
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
        private matrixService: MatrixService) { }

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
            } else {
                this.messageService.add(result.error);
                return;
            }
        }
        this.messageService.add('Stepping...');
        this.executingState();
        try {
            this.mainMethodTextEditor.setReadOnly(true);
            this.mainMethodTextEditor.setReadOnly(true);
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

    private createJerooCode() {
        let jerooCode = '';
        if (this.selectedLanguage === SelectedLanguage.Java) {
            jerooCode += '@Java\n';
        } else if (this.selectedLanguage === SelectedLanguage.Vb) {
            jerooCode += '@VB\n';
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
}
