import { Component, ViewChild, AfterViewInit, ElementRef } from '@angular/core';
import { MatrixService } from '../matrix.service';
import { SelectedLanguage } from './SelectedLanguage';
import { JerooMatrixComponent } from '../jeroo-matrix/jeroo-matrix.component';
import { TextEditorComponent } from '../text-editor/text-editor.component';
import { BytecodeInterpreterService } from '../bytecode-interpreter.service';

interface Language {
    value: SelectedLanguage;
    viewValue: string;
}

@Component({
    selector: 'app-dashboard',
    templateUrl: './dashboard.component.html',
    styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent implements AfterViewInit {
    @ViewChild('mapFileInput') mapFileInput: ElementRef;
    @ViewChild('jerooMatrix') jerooMatrix: JerooMatrixComponent;
    @ViewChild('mapSaver') mapSaver: ElementRef;
    @ViewChild('mainMethodTextEditor') mainMethodTextEditor: TextEditorComponent;
    @ViewChild('extensionMethodsTextEditor') extensionMethodsTextEditor: TextEditorComponent;

    selectedLanguage = SelectedLanguage.Java;
    languages: Language[] = [
        { viewValue: 'JAVA/C++/C#', value: SelectedLanguage.Java },
        { viewValue: 'VB.NET', value: SelectedLanguage.Vb },
        { viewValue: 'PYTHON', value: SelectedLanguage.Python }
    ];

    selectedEditor: TextEditorComponent = null;

    constructor(private bytecodeService: BytecodeInterpreterService, private matrixService: MatrixService) { }

    ngAfterViewInit() {
        this.selectedEditor = this.mainMethodTextEditor;
    }

    runCode() {
        const jerooCode = this.createJerooCode();
        console.log(jerooCode);
        const result = JerooCompiler.compile(jerooCode);
        const context = this.jerooMatrix.getCanvas().getContext('2d');
        if (result.successful) {
            const instructions = result.bytecode;
            this.bytecodeService.executeInstructions(instructions, this.matrixService, context);
        }
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

    clearMap() {
        this.matrixService.resetMap();
        this.jerooMatrix.redraw();
    }

    openMapFile() {
        (this.mapFileInput.nativeElement as HTMLInputElement).click();
    }

    mapFileSelected(file: File) {
        const reader = new FileReader();
        reader.readAsText(file, 'UTF-8');
        reader.onload = (readerEvent: any) => {
            const content: string = readerEvent.target.result;
            this.matrixService.genMapFromString(content);
            this.jerooMatrix.redraw();
        };
    }

    saveMapFile() {
        const mapSaver = (this.mapSaver.nativeElement as HTMLAnchorElement);
        // kind of a hack to get the browser to save the map data to a file
        const saveBlob = (function() {
            return function(b: Blob, fileName: string) {
                const url = window.URL.createObjectURL(b);
                mapSaver.href = url;
                mapSaver.download = fileName;
                mapSaver.click();
                window.URL.revokeObjectURL(url);
            };
        }());

        const jerooMapString = this.matrixService.toString();
        const blob = new Blob([jerooMapString], {
            type: 'text/plain'
        });
        saveBlob(blob, 'map.jev');
    }

    printMap() {
        const dataUrl = this.jerooMatrix.getCanvas().toDataURL();
        const windowContent = `
<!DOCTYPE html>
<html>
<head><title>Jeroo Map</title></head>
<body>
<img src="${dataUrl}">
</body>
</html>
`;
        const printWindow = window.open('', '', 'width=340,height=260');
        printWindow.document.open();
        printWindow.document.write(windowContent);
        printWindow.document.close();
        printWindow.print();
        printWindow.close();
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

    onEditorTabIndexChange(index: number) {
        if (index === 0) {
            this.selectedEditor = this.mainMethodTextEditor;
        } else if (index === 1) {
            this.selectedEditor = this.extensionMethodsTextEditor;
        }
    }

    onUndoClick() {
        this.selectedEditor.undo();
    }

    onRedoClick() {
        this.selectedEditor.redo();
    }

    onToggleCommentLines() {
        this.selectedEditor.toggleComment();
    }

    onIndentSelectionClick() {
        this.selectedEditor.indentSelection();
    }

    onUnindentSelectionClick() {
        this.selectedEditor.unindentSelection();
    }

    onFormatSelectionClick() {
        this.selectedEditor.formatSelection();
    }
}
