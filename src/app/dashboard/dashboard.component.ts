import { AfterViewInit, Component, ElementRef, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Hotkey, HotkeysService } from 'angular2-hotkeys';
import { CacheDialogComponent } from '../cache-dialog/cache-dialog.component';
import { DashboardDialogAboutComponent } from './dashboard-dialog-about/dashboard-dialog-about.component';
import { DashboardDialogAwardsComponent } from './dashboard-dialog-awards/dashboard-dialog-awards.component';
import { DashboardDialogCopyrightComponent } from './dashboard-dialog-copyright/dashboard-dialog-copyright.component';
import { DashboardDialogHistoryComponent } from './dashboard-dialog-history/dashboard-dialog-history.component';
import { EditorState, EditorTabAreaComponent } from '../editor-tab-area/editor-tab-area.component';
import { JerooMatrixComponent } from '../jeroo-matrix/jeroo-matrix.component';
import { MatrixService } from '../matrix.service';
import { MessageService } from '../message.service';
import { PrintService } from '../print.service';
import { CodeService } from '../code.service';
import { EditorPreferencesComponent } from './editor-preferences/editor-preferences.component';
import { CodeSaveDialogComponent } from './code-save-dialog/code-save-dialog.component';
import { IslandSaveDialogComponent } from './island-save-dialog/island-save-dialog.component';

interface Speed {
  name: string;
  value: number;
}

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent implements AfterViewInit {
  @ViewChild('mapFileInput', { static: true }) mapFileInput: ElementRef;
  @ViewChild('codeFileInput', { static: true }) codeFileInput: ElementRef;
  @ViewChild('jerooMatrix', { static: true }) jerooMatrix: JerooMatrixComponent;
  @ViewChild('jerooEditor', { static: true }) jerooEditor: EditorTabAreaComponent;
  @ViewChild('fileSaver', { static: true }) fileSaver: ElementRef;

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
    private printService: PrintService,
    private codeService: CodeService,
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
      this.saveIsland();
      return false;
    }));
    this.hotkeysService.add(new Hotkey('ctrl+shift+p', (_event: KeyboardEvent): boolean => {
      this.printIsland();
      return false;
    }));
    this.hotkeysService.add(new Hotkey('f8', (_event: KeyboardEvent): boolean => {
      window.open(this.getHelpUrl());
      return false;
    }));
    this.hotkeysService.add(new Hotkey('ctrl+n', (_event: KeyboardEvent): boolean => {
      this.newCodeFile();
      return false;
    }));
    this.hotkeysService.add(new Hotkey('ctrl+o', (_event: KeyboardEvent): boolean => {
      this.openCodeFile();
      return false;
    }));
    this.hotkeysService.add(new Hotkey('ctrl+s', (_event: KeyboardEvent): boolean => {
      this.saveCode();
      return false;
    }));
    this.hotkeysService.add(new Hotkey('ctrl+p', (_event: KeyboardEvent): boolean => {
      this.printCode();
      return false;
    }));
  }

  ngAfterViewInit() {
    if (this.jerooEditor.hasCachedCode() || this.jerooEditor.hasCachedConfig() || this.jerooMatrix.hasCachedMatrix()) {
      // setTimeout prevents a console error
      // see: https://github.com/angular/material2/issues/5268
      setTimeout(() => {
        const dialogRef = this.dialog.open(CacheDialogComponent);
        dialogRef.afterClosed().subscribe(loadCache => {
          if (loadCache) {
            if (this.jerooEditor.hasCachedCode()) {
              this.jerooEditor.loadCodeFromCache();
            }

            if (this.jerooEditor.hasCachedConfig()) {
              this.jerooEditor.loadPreferencesFromCache();
            }

            if (this.jerooMatrix.hasCachedMatrix()) {
              this.jerooMatrix.loadMatrixFromCache();
            }
          } else {
            this.jerooEditor.resetCache();
            this.jerooEditor.resetPreferences();
            this.jerooMatrix.resetCache();
          }
        });
      });
    }
  }

  newCodeFile() {
    this.jerooEditor.clearCode();
  }

  openCodeFile() {
    (this.codeFileInput.nativeElement as HTMLInputElement).click();
  }

  codeFileSelected(file: File) {
    if (this.editorEditingEnabled()) {
      const reader = new FileReader();
      reader.readAsText(file, 'UTF-8');
      reader.onload = (readerEvent: any) => {
        const content: string = readerEvent.target.result;
        this.codeService.loadCodeFromStr(content);
      };
    }
  }

  saveCode() {
    this.dialog.open(CodeSaveDialogComponent);
  }

  printCode() {
    this.printService.printDocument('code');
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

  onEditorPreferenceClick() {
    this.dialog.open(EditorPreferencesComponent);
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
      this.jerooMatrix.resetState();
    }
  }

  onPauseClick() {
    if (!this.pauseBtnDisabled()) {
      this.jerooEditor.pauseState();
      this.messageService.addErrorMessage('Program paused by user');
    }
  }

  onStopClick() {
    if (!this.stopBtnDisabled()) {
      this.jerooEditor.stopState();
      this.messageService.clear();
      this.messageService.addErrorMessage('Program stopped by user');
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
    if (this.islandEditingEnabled()) {
      const reader = new FileReader();
      reader.readAsText(file, 'UTF-8');
      reader.onload = (readerEvent: any) => {
        const content: string = readerEvent.target.result;
        this.matrixService.genMapFromString(content);
        this.jerooMatrix.redraw();
      };
    }
  }

  saveIsland() {
    this.dialog.open(IslandSaveDialogComponent);
  }

  printIsland() {
    this.printService.printDocument('map');
  }

  changeMapSize() {
    this.jerooMatrix.openDialog();
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

  islandEditingEnabled() {
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
