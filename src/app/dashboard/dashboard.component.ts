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
import * as Mousetrap from 'mousetrap';
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
import { CodeSaveToServerDialogComponent } from './code-save-to-server-dialog/code-save-to-server-dialog.component';
import { IslandSaveToServerDialogComponent } from './island-save-to-server-dialog/island-save-to-server-dialog.component';
import { CodeOpenDialogComponent } from './code-open-dialog/code-open-dialog.component';
import { IslandOpenDialogComponent } from './island-open-dialog/island-open-dialog.component';
import { SelectedTileTypeService } from '../selected-tile-type.service';
import { TileType } from '../tileType';
import { EditorWarningDialogComponent } from '../editor-warning-dialog/editor-warning-dialog.component';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent implements AfterViewInit {
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

  jerooEditorState: EditorState = {
    reset: true,
    executing: false,
    paused: false,
    stopped: false
  };

  constructor(
    private islandService: IslandService,
    private messageService: MessageService,
    private printService: PrintService,
    private selectedTileTypeService: SelectedTileTypeService,
    public dialog: MatDialog,
  ) { }

  ngAfterViewInit() {
    const mousetrap = new Mousetrap(document.body);
    mousetrap.bind('f2', () => {
      this.onResetClick();
      return false;
    });
    mousetrap.bind('f3', () => {
      this.onRunStepwiseClick();
      return false;
    });
    mousetrap.bind('f4', () => {
      this.onRunContiniousClick();
      return false;
    });
    mousetrap.bind('f5', () => {
      this.onPauseClick();
      return false;
    });
    mousetrap.bind('f6', () => {
      this.onStopClick();
      return false;
    });
    mousetrap.bind('ctrl+shift+n', () => {
      this.clearIsland();
      return false;
    });
    mousetrap.bind('ctrl+shift+o', () => {
      this.openIslandFile();
      return false;
    });
    mousetrap.bind('ctrl+shift+s', () => {
      this.saveIsland();
      return false;
    });
    mousetrap.bind('ctrl+shift+p', () => {
      this.printIsland();
      return false;
    });
    mousetrap.bind('f8', () => {
      window.open(this.getHelpUrl());
      return false;
    });
    mousetrap.bind('ctrl+n', () => {
      this.newCodeFile();
      return false;
    });
    mousetrap.bind('ctrl+o', () => {
      this.openCodeFile();
      return false;
    });
    mousetrap.bind('ctrl+s', () => {
      this.saveCodeToServer();
      return false;
    });
    mousetrap.bind('ctrl+p', () => {
      this.printCode();
      return false;
    });
    mousetrap.bind('ctrl+shift+f', () => {
      this.onFormatClick();
      return false;
    });
    if ((this.jerooEditor?.hasCachedCode() || this.jerooEditor?.hasCachedConfig() || this.jerooIsland?.hasCachedIsland())) {
      // setTimeout prevents a console error
      // see: https://github.com/angular/material2/issues/5268
      setTimeout(() => {
        const dialogRef = this.dialog.open(CacheDialogComponent);
        dialogRef.afterClosed().subscribe(loadCache => {
          if (loadCache) {
            this.loadEditorFromCache();
          } else {
            // warn about deleting the previously saved editor
            this.dialog.open(EditorWarningDialogComponent)
              .afterClosed().subscribe((cont) => {
                if (cont) {
                  this.jerooEditor?.resetCache();
                  this.jerooEditor?.resetPreferences();
                  this.jerooIsland?.resetCache();
                } else {
                  this.loadEditorFromCache();
                }
              });
          }
        });
      });
    }
  }

  loadEditorFromCache() {
    if (this.jerooEditor?.hasCachedCode()) {
      this.jerooEditor?.loadCodeFromCache();
    }

    if (this.jerooEditor?.hasCachedConfig()) {
      this.jerooEditor?.loadPreferencesFromCache();
    }

    if (this.jerooIsland?.hasCachedIsland()) {
      this.jerooIsland?.loadIslandFromCache();
    }
  }

  newCodeFile() {
    this.dialog.open(EditorWarningDialogComponent)
      .afterClosed().subscribe((cont) => {
        if (cont) {
          this.jerooEditor?.clearCode();
        }
      });
  }

  openCodeFile() {
    const codeFileInput = this.codeFileInput?.nativeElement as HTMLInputElement;
    codeFileInput.click();
  }

  codeFileSelected(file: File) {
    if (this.editorEditingEnabled()) {
      const reader = new FileReader();
      reader.readAsText(file, 'UTF-8');
      reader.onload = (readerEvent: any) => {
        const content: string = readerEvent.target.result;
        this.jerooEditor?.loadCode(content);
      };
    }
  }

  saveCode() {
    const dialogConfig = new MatDialogConfig();
    dialogConfig.data = {
      editorCode: this.jerooEditor?.getCode()
    };
    this.dialog.open(CodeSaveDialogComponent, dialogConfig);
  }

  saveCodeToServer() {
    const dialogConfig = new MatDialogConfig();
    dialogConfig.data = {
      editorCode: this.jerooEditor?.getCode()
    };
    this.dialog.open(CodeSaveToServerDialogComponent, dialogConfig);
  }

  openCodeFileFromServer() {
    const dialogConfig = new MatDialogConfig();
    dialogConfig.data = {
      jerooEditor: this.jerooEditor
    };
    this.dialog.open(CodeOpenDialogComponent, dialogConfig);
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
    this.jerooEditor?.undo();
  }

  onRedoClick() {
    this.jerooEditor?.redo();
  }

  onToggleCommentLines() {
    this.jerooEditor?.toggleComment();
  }

  onIndentSelectionClick() {
    this.jerooEditor?.indentSelection();
  }

  onUnindentSelectionClick() {
    this.jerooEditor?.unindentSelection();
  }

  onFormatClick() {
    this.jerooEditor?.format();
  }

  onEditorPreferenceClick() {
    this.dialog.open(EditorPreferencesComponent);
  }

  onRunStepwiseClick() {
    if (!this.runBtnDisabled()) {
      const context = this.jerooIsland?.getContext();
      if (context) {
        this.jerooEditor?.runStepwise(context);
      }
    }
  }

  onRunContiniousClick() {
    if (!this.runBtnDisabled()) {
      const context = this.jerooIsland?.getContext();
      if (context) {
        this.jerooEditor?.runContinious(context);
      }
    }
  }

  onResetClick() {
    if (!this.resetBtnDisabled()) {
      this.jerooEditor?.resetState();
      this.jerooIsland?.resetState();
    }
  }

  onPauseClick() {
    if (!this.pauseBtnDisabled()) {
      this.jerooEditor?.pauseState();
      const message = new LoggingMessage('Program paused by user');
      this.messageService.addMessage(message);
    }
  }

  onStopClick() {
    if (!this.stopBtnDisabled()) {
      this.jerooEditor?.stopState();
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
    if (this.jerooEditorState.reset) {
      this.jerooIsland?.clearIsland();
    }
  }

  openIslandFile() {
    const islandFileInput = this.islandFileInput?.nativeElement as HTMLInputElement;
    islandFileInput.click();
  }

  islandFileSelected(file: File) {
    if (this.islandEditingEnabled()) {
      const reader = new FileReader();
      reader.readAsText(file, 'UTF-8');
      reader.onload = (readerEvent: any) => {
        const content: string = readerEvent.target.result;
        this.islandService.genIslandFromString(content);
        this.jerooIsland?.redraw();
        this.jerooIsland?.saveInLocal(content);
      };
    }
  }

  saveIsland() {
    this.dialog.open(IslandSaveDialogComponent);
  }

  saveIslandToServer() {
    this.dialog.open(IslandSaveToServerDialogComponent);
  }

  openIslandFileFromServer() {
    const dialogConfig = new MatDialogConfig();
    dialogConfig.data = {
      jerooEditor: this.jerooEditor
    };
    this.dialog.open(IslandOpenDialogComponent, dialogConfig);
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
}
