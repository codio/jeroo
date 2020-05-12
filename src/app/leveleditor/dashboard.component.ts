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

import { AfterViewInit, Component, ElementRef, ViewChild } from '@angular/core';
import { MatDialog, MatDialogConfig } from '@angular/material/dialog';
import { Hotkey, HotkeysService } from 'angular2-hotkeys';
import { CacheDialogComponent } from '../cache-dialog/cache-dialog.component';
import { DashboardDialogAboutComponent } from './dashboard-dialog-about/dashboard-dialog-about.component';
import { DashboardDialogAwardsComponent } from './dashboard-dialog-awards/dashboard-dialog-awards.component';
import { DashboardDialogCopyrightComponent } from './dashboard-dialog-copyright/dashboard-dialog-copyright.component';
import { DashboardDialogHistoryComponent } from './dashboard-dialog-history/dashboard-dialog-history.component';
import { EditorState, EditorTabsComponent } from '../editor-tabs/editor-tabs.component';
import { JerooIslandComponent } from '../island/island.component';
import { IslandService } from '../island.service';
import { MessageService, LoggingMessage } from '../message.service';
import { PrintService } from '../print.service';
import { EditorPreferencesComponent } from './editor-preferences/editor-preferences.component';
import { CodeSaveDialogComponent } from './code-save-dialog/code-save-dialog.component';
import { IslandSaveDialogComponent } from './island-save-dialog/island-save-dialog.component';
import { SelectedTileTypeService } from '../selected-tile-type.service';
import { TileType } from '../tileType';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class LevelEditorComponent implements AfterViewInit {
  @ViewChild('islandFileInput', { static: true }) islandFileInput: ElementRef | null = null;
  @ViewChild('codeFileInput', { static: true }) codeFileInput: ElementRef | null = null;
  @ViewChild('jerooIsland', { static: true }) jerooIsland: JerooIslandComponent | null = null;
  @ViewChild('jerooEditor', { static: true }) jerooEditor: EditorTabsComponent | null = null;
  @ViewChild('fileSaver', { static: true }) fileSaver: ElementRef | null = null;

  private speeds = [475, 350, 225, 125, 25, 2];
  speedIndex = 3;
  runtimeSpeed = this.speeds[this.speedIndex - 1];
  speedRadios = [
    { name: '1 - Slow', value: 1 },
    { name: '2', value: 2 },
    { name: '3 - Medium', value: 3 },
    { name: '4', value: 4 },
    { name: '5 - Fast', value: 5 },
    { name: '6 - Max', value: 6 }
  ];

  private tileTypes = [TileType.Grass, TileType.Water, TileType.Flower, TileType.Net];
  // set the default selected tile to whatever is in the service
  tileTypeIndex = this.tileTypes.indexOf(this.selectedTileTypeService.selectedTileType);
  editTypeIndex = 0;
  jerooEditorState: EditorState = {
    reset: true,
    executing: false,
    paused: false,
    stopped: false
  };

  constructor(
    private islandService: IslandService,
    private hotkeysService: HotkeysService,
    private messageService: MessageService,
    private printService: PrintService,
    private selectedTileTypeService: SelectedTileTypeService,
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
      this.clearIsland();
      return false;
    }));
    this.hotkeysService.add(new Hotkey('ctrl+shift+o', (_event: KeyboardEvent): boolean => {
      this.openIslandFile();
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
    if (
      (this.jerooEditor && this.jerooIsland) &&
      (this.jerooEditor.hasCachedCode() || this.jerooEditor.hasCachedConfig() || this.jerooIsland.hasCachedIsland())
    ) {
      // setTimeout prevents a console error
      // see: https://github.com/angular/material2/issues/5268
      setTimeout(() => {
        const dialogRef = this.dialog.open(CacheDialogComponent);
        dialogRef.afterClosed().subscribe(loadCache => {
          if (this.jerooEditor && this.jerooIsland) {
            if (loadCache) {
              if (this.jerooEditor.hasCachedCode()) {
                this.jerooEditor.loadCodeFromCache();
              }

              if (this.jerooEditor.hasCachedConfig()) {
                this.jerooEditor.loadPreferencesFromCache();
              }

              if (this.jerooIsland.hasCachedIsland()) {
                this.jerooIsland.loadIslandFromCache();
              }
            } else {
              this.jerooEditor.resetCache();
              this.jerooEditor.resetPreferences();
              this.jerooIsland.resetCache();
            }
          }
        });
      });
    }
  }


  undoLevelEdit() {
    if (this.jerooIsland) {
      this.jerooIsland.undo();
    }

  }

  cursorRight() {
    if (this.jerooIsland) {
      this.jerooIsland.cursorRight();
    }
  }

  cursorLeft() {
    if (this.jerooIsland) {
      this.jerooIsland.cursorLeft();
    }
  }
  cursorUp() {
    if (this.jerooIsland) {
      this.jerooIsland.cursorUp();
    }
  }
  cursorDown() {
    if (this.jerooIsland) {
      this.jerooIsland.cursorDown();
    }
  }
  cursorEnter() {
    if (this.jerooIsland) {
      this.jerooIsland.cursorEnter();
    }
  }
  newCodeFile() {
    if (this.jerooEditor) {
      this.jerooEditor.clearCode();
    }
  }

  openCodeFile() {
    if (this.codeFileInput) {
      const codeFileInput = this.codeFileInput.nativeElement as HTMLInputElement;
      codeFileInput.click();
    }
  }

  codeFileSelected(file: File) {
    if (this.editorEditingEnabled()) {
      const reader = new FileReader();
      reader.readAsText(file, 'UTF-8');
      reader.onload = (readerEvent: any) => {
        if (this.jerooEditor) {
          const content: string = readerEvent.target.result;
          this.jerooEditor.loadCode(content);
        }
      };
    }
  }

  saveCode() {
    if (this.jerooEditor) {
      const dialogConfig = new MatDialogConfig();
      dialogConfig.data = {
        editorCode: this.jerooEditor.getCode()
      };
      this.dialog.open(CodeSaveDialogComponent, dialogConfig);
    }
  }

  printCode() {
    if (this.jerooEditor) {
      const editorCode = this.jerooEditor.getCode();
      if (editorCode) {
        this.printService.printCode(editorCode);
      }
    }
  }

  onUndoClick() {
    if (this.jerooEditor) {
      this.jerooEditor.undo();
    }
  }

  onRedoClick() {
    if (this.jerooEditor) {
      this.jerooEditor.redo();
    }
  }

  onToggleCommentLines() {
    if (this.jerooEditor) {
      this.jerooEditor.toggleComment();
    }
  }

  onIndentSelectionClick() {
    if (this.jerooEditor) {
      this.jerooEditor.indentSelection();
    }
  }

  onUnindentSelectionClick() {
    if (this.jerooEditor) {
      this.jerooEditor.unindentSelection();
    }
  }

  onFormatClick() {
    if (this.jerooEditor) {
      this.jerooEditor.format();
    }
  }

  onEditorPreferenceClick() {
    this.dialog.open(EditorPreferencesComponent);
  }

  onRunStepwiseClick() {
    if (this.jerooEditor && this.jerooIsland && !this.runBtnDisabled()) {
      const context = this.jerooIsland.getContext();
      if (context) {
        this.jerooEditor.runStepwise(context);
      }
    }
  }

  onRunContiniousClick() {
    if (this.jerooEditor && this.jerooIsland && !this.runBtnDisabled()) {
      const context = this.jerooIsland.getContext();
      if (context) {
        this.jerooEditor.runContinious(context);
      }
    }
  }

  onResetClick() {
    if (this.jerooEditor && this.jerooIsland && !this.resetBtnDisabled()) {
      this.jerooEditor.resetState();
      this.jerooIsland.resetState();
    }
  }

  onPauseClick() {
    if (this.jerooEditor && !this.pauseBtnDisabled()) {
      this.jerooEditor.pauseState();
      const message = new LoggingMessage('Program paused by user');
      this.messageService.addMessage(message);
    }
  }

  onStopClick() {
    if (this.jerooEditor && !this.stopBtnDisabled()) {
      this.jerooEditor.stopState();
      this.messageService.clear();
      const message = new LoggingMessage('Program stopped by user');
      this.messageService.addMessage(message);
    }
  }

  onSpeedRadioClick(speedValue: number) {
    this.speedIndex = speedValue;
    this.onSpeedIndexChange();
  }

  onSpeedIndexChange() {
    this.runtimeSpeed = this.speeds[this.speedIndex - 1];
  }

  clearIsland() {
    if (this.jerooIsland && this.jerooEditorState.reset) {
      this.jerooIsland.clearIsland();
    }
  }

  openIslandFile() {
    if (this.islandFileInput) {
      const islandFileInput = this.islandFileInput.nativeElement as HTMLInputElement;
      islandFileInput.click();
    }
  }

  islandFileSelected(file: File) {
    if (this.islandEditingEnabled()) {
      const reader = new FileReader();
      reader.readAsText(file, 'UTF-8');
      reader.onload = (readerEvent: any) => {
        if (this.jerooIsland) {
          const content: string = readerEvent.target.result;
          this.islandService.genIslandFromString(content);
          this.jerooIsland.redraw();
          this.jerooIsland.saveInLocal(content);
        }
      };
    }
  }

  saveIsland() {
    this.dialog.open(IslandSaveDialogComponent);
  }

  printIsland() {
    this.printService.printIsland();
  }

  changeIslandSize() {
    if (this.jerooIsland) {
      this.jerooIsland.openDialog();
    }
  }

  getHelpUrl() {
    if (this.jerooEditor) {
      return this.jerooEditor.getHelpUrl();
    }
  }

  getTutorialUrl() {
    if (this.jerooEditor) {
      return this.jerooEditor.getTutorialUrl();
    }
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

  onTileTypeRadioClick(tileTypeIndex: number) {
    this.selectedTileTypeService.selectedTileType = this.tileTypes[tileTypeIndex];
  }
  onEditTypeRadioClick(tileTypeIndex: number) {
    if (this.jerooIsland) {
      this.jerooIsland.setEditType(tileTypeIndex);
    }

  }
}
