import { Component, ElementRef, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material';
import { Hotkey, HotkeysService } from 'angular2-hotkeys';
import { DashboardDialogAwardsComponent } from '../dashboard-dialog-awards/dashboard-dialog-awards.component';
import { DashboardDialogCopyrightComponent } from '../dashboard-dialog-copyright/dashboard-dialog-copyright.component';
import { DashboardDialogHistoryComponent } from '../dashboard-dialog-history/dashboard-dialog-history.component';
import { EditorState, EditorTabAreaComponent } from '../editor-tab-area/editor-tab-area.component';
import { JerooMatrixComponent } from '../jeroo-matrix/jeroo-matrix.component';
import { MatrixService } from '../matrix.service';
import { MessageService } from '../message.service';
import { DashboardDialogAboutComponent } from '../dashboard-dialog-about/dashboard-dialog-about.component';

interface Speed {
    name: string;
    value: number;
}

@Component({
    selector: 'app-dashboard',
    templateUrl: './dashboard.component.html',
    styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent {
    @ViewChild('mapFileInput') mapFileInput: ElementRef;
    @ViewChild('jerooMatrix') jerooMatrix: JerooMatrixComponent;
    @ViewChild('jerooEditor') jerooEditor: EditorTabAreaComponent;
    @ViewChild('mapSaver') mapSaver: ElementRef;

    private speeds = [475, 350, 225, 125, 25, 2];
    runtimeSpeed = this.speeds[2];
    speedIndex = 3;
    speedsRadio: Speed[] = [
        { name: '1 - Slow', value: 1 },
        { name: '2', value: 2 },
        { name: '3 - Medium', value: 3 },
        { name: '4', value: 4 },
        { name: '5 - Fast', value: 5 },
        { name: '6 - Max', value: 6 }
    ];
    selectedSpeedRadio = this.speedsRadio[2].value;

    jerooEditorState: EditorState = {
        reset: true,
        executing: false,
        paused: false,
        stopped: false
    };

    constructor(
        private matrixService: MatrixService,
        private hotkeysService: HotkeysService,
        private messageService: MessageService,
        public dialog: MatDialog
    ) {
        this.hotkeysService.add(new Hotkey('f2', (_event: KeyboardEvent): boolean => {
            this.onResetClick();
            return false;
        }));
        this.hotkeysService.add(new Hotkey('f3', (_event: KeyboardEvent): boolean => {
            this.onRunStepwiseClick();
            return false;
        }));
        this.hotkeysService.add(new Hotkey('f4', (_event: KeyboardEvent): boolean => {
            this.onRunContiniousClick();
            return false;
        }));
        this.hotkeysService.add(new Hotkey('f5', (_event: KeyboardEvent): boolean => {
            this.onPauseClick();
            return false;
        }));
        this.hotkeysService.add(new Hotkey('f6', (_event: KeyboardEvent): boolean => {
            this.onStopClick();
            return false;
        }));
        this.hotkeysService.add(new Hotkey('ctrl+shift+n', (_event: KeyboardEvent): boolean => {
            this.clearMap();
            return false;
        }));
        this.hotkeysService.add(new Hotkey('ctrl+shift+o', (_event: KeyboardEvent): boolean => {
            this.openMapFile();
            return false;
        }));
        this.hotkeysService.add(new Hotkey('ctrl+shift+s', (_event: KeyboardEvent): boolean => {
            this.saveMapFile();
            return false;
        }));
        this.hotkeysService.add(new Hotkey('ctrl+shift+p', (_event: KeyboardEvent): boolean => {
            this.printMap();
            return false;
        }));
        this.hotkeysService.add(new Hotkey('f8', (_event: KeyboardEvent): boolean => {
            window.open(this.getHelpUrl());
            return false;
        }));
    }

    onUndoClick() {
        this.jerooEditor.undo();
    }

    onRedoClick() {
        this.jerooEditor.redo();
    }

    onToggleCommentLines() {
        this.jerooEditor.toggleComment();
    }

    onIndentSelectionClick() {
        this.jerooEditor.indentSelection();
    }

    onUnindentSelectionClick() {
        this.jerooEditor.unindentSelection();
    }

    onFormatSelectionClick() {
        this.jerooEditor.formatSelection();
    }

    onRunStepwiseClick() {
        if (!this.runBtnDisabled()) {
            this.jerooEditor.runStepwise(this.jerooMatrix.getContext());
        }
    }

    onRunContiniousClick() {
        if (!this.runBtnDisabled()) {
            this.jerooEditor.runContinious(this.jerooMatrix.getContext());
        }
    }

    onResetClick() {
        if (!this.resetBtnDisabled()) {
            this.jerooEditor.resetState();
            this.matrixService.resetJeroos();
            this.jerooMatrix.redraw();
        }
    }

    onPauseClick() {
        if (!this.pauseBtnDisabled()) {
            this.jerooEditor.pauseState();
            this.messageService.add('Program paused by user');
        }
    }

    onStopClick() {
        if (!this.stopBtnDisabled()) {
            this.jerooEditor.stopState();
            this.messageService.clear();
            this.messageService.add('Program stopped by user');
        }
    }

    onSpeedRadioClick(speedValue: number) {
        this.speedIndex = speedValue;
        this.onSpeedIndexChange();
    }

    onSpeedIndexChange() {
        this.runtimeSpeed = this.speeds[this.speedIndex - 1];
    }

    clearMap() {
        if (this.jerooEditorState.reset) {
            this.jerooMatrix.clearMap();
        }
    }

    openMapFile() {
        (this.mapFileInput.nativeElement as HTMLInputElement).click();
    }

    mapFileSelected(file: File) {
        if (this.jerooEditorState.reset) {
            const reader = new FileReader();
            reader.readAsText(file, 'UTF-8');
            reader.onload = (readerEvent: any) => {
                const content: string = readerEvent.target.result;
                this.matrixService.genMapFromString(content);
                this.jerooMatrix.redraw();
            };
        }
    }

    saveMapFile() {
        const mapSaver = (this.mapSaver.nativeElement as HTMLAnchorElement);
        // kind of a hack to get the browser to save the map data to a file
        const saveBlob = (function () {
            return function (b: Blob, fileName: string) {
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

    getHelpUrl() {
        return this.jerooEditor.getHelpUrl();
    }

    getTutorialUrl() {
        return this.jerooEditor.getTutorialUrl();
    }

    resetBtnDisabled() {
        return !this.jerooEditorState.reset
            && !this.jerooEditorState.paused
            && !this.jerooEditorState.stopped;
    }

    runBtnDisabled() {
        return !this.jerooEditorState.paused && !this.jerooEditorState.reset;
    }

    pauseBtnDisabled() {
        return !this.jerooEditorState.executing;
    }

    stopBtnDisabled() {
        return !this.jerooEditorState.executing && !this.jerooEditorState.paused;
    }

    matrixEditingEnabled() {
        return this.jerooEditorState.reset;
    }

    editorEditingEnabled() {
        return !this.jerooEditorState.executing && !this.jerooEditorState.stopped && !this.jerooEditorState.paused;
    }

    openAboutJeroo() {
        this.dialog.open(DashboardDialogAboutComponent);
    }

    openAwards() {
        this.dialog.open(DashboardDialogAwardsComponent);
    }

    openHistory() {
        this.dialog.open(DashboardDialogHistoryComponent);
    }

    openCopyright() {
        this.dialog.open(DashboardDialogCopyrightComponent);
    }
}
