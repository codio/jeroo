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

import { AfterViewInit, Component, ElementRef, Inject, Input, ViewChild } from '@angular/core';
import { MatDialog, MatDialogConfig } from '@angular/material/dialog';
import { LOCAL_STORAGE, WebStorageService } from 'angular-webstorage-service';
import { BytecodeInterpreterService } from '../bytecode-interpreter/bytecode-interpreter.service';
import { DialogData, ChnageIslandSizeDialogComponent } from '../change-island-size-dialog/change-island-size-dialog.component';
import { IslandService } from '../island.service';
import { Storage } from '../storage';
import { WarningDialogComponent } from '../warning-dialog/warning-dialog.component';
import { SelectedTileTypeService } from '../selected-tile-type.service';

@Component({
  selector: 'app-jeroo-island',
  templateUrl: './island.component.html',
  styleUrls: ['./island.component.scss']
})
export class JerooIslandComponent implements AfterViewInit {
  @ViewChild('jerooGameCanvas', { static: true }) jerooGameCanvas: ElementRef | null = null;
  @Input() editingEnabled = true;

  mouseRow: number | null = null;
  mouseColumn: number | null = null;
  private canvas: HTMLCanvasElement | null = null;
  private context: CanvasRenderingContext2D | null = null;
  private mouseDown = false;
  private toggle = true;

  constructor(private islandService: IslandService, private dialog: MatDialog,
    public bytecodeService: BytecodeInterpreterService,
    private selectedTileTypeService: SelectedTileTypeService,
    @Inject(LOCAL_STORAGE) private storage: WebStorageService
  ) { }


  getToggle() {
    return this.toggle;
  }

  setToggle() {
    this.toggle = !this.toggle;
  }
  ngAfterViewInit() {
    if (this.jerooGameCanvas) {
      // check if something has been stored in the cache to load if it has
      this.canvas = this.jerooGameCanvas.nativeElement as HTMLCanvasElement;
      this.context = this.canvas.getContext('2d');
      this.canvas.width = this.canvas.offsetWidth;
      this.canvas.height = this.canvas.offsetHeight;
      this.redraw();
    }
  }

  loadIslandFromCache() {
    const cachedIsland = this.storage.get(Storage.Board);
    if (cachedIsland) {
      this.islandService.genIslandFromString(cachedIsland);
      this.redraw();
    }
  }

  resetCache() {
    this.storage.remove(Storage.Board);
    this.redraw();
  }

  openDialog() {
    const dialogConfig = new MatDialogConfig();
    dialogConfig.autoFocus = true;
    dialogConfig.data = {
      colValue: this.islandService.getCols() - 2,
      rowValue: this.islandService.getRows() - 2
    };

    const dialogRef = this.dialog.open(ChnageIslandSizeDialogComponent, dialogConfig);
    dialogRef.afterClosed().subscribe((data: DialogData) => {
      if (data && this.editingEnabled) {
        this.islandService.setCols(+data.colValue + 2);
        this.islandService.setRows(+data.rowValue + 2);
        this.islandService.resetIsland();
        this.islandService.resetDynamicIsland();
        this.islandService.resetJeroos();
        this.redraw();
        this.saveInLocal(this.islandService.toString());
      }
    });
  }

  redraw() {
    if (this.canvas && this.context) {
      this.context.clearRect(0, 0,
        this.canvas.width,
        this.canvas.height
      );
      this.canvas.width = this.islandService.getTsize() * (this.islandService.getCols());
      this.canvas.height = this.islandService.getTsize() * (this.islandService.getRows());
      // if the board has been resized save into cache
      this.islandService.render(this.context);
    }
  }

  getIslandCols() {
    // let numbers = Array(this.islandService.getCols()).fill(0,this.islandService.getCols(),this.islandService.getCols()); // [0,1,2,3,4]
    const numbers = Array.from(Array(this.islandService.getCols()).keys());
    return numbers;

  }

  getIslandRows() {
    // let numbers = Array(this.islandService.getRows()).fill(0,this.islandService.getRows(),this.islandService.getRows())
    const numbers = Array.from(Array(this.islandService.getRows()).keys()); // [0,1,2,3,4]
    return numbers;

  }
  clearIsland() {
    const dialogRef = this.dialog.open(WarningDialogComponent);
    dialogRef.afterClosed().subscribe((cont) => {
      if (cont && this.context) {
        this.islandService.resetIsland();
        this.islandService.resetJeroos();
        this.islandService.resetDynamicIsland();
        this.saveInLocal(this.islandService.toString());
        this.islandService.render(this.context);
      }
    });
  }

  getCanvas() {
    return this.canvas;
  }

  getContext() {
    return this.context;
  }

  canvasGestureUp() {
    this.mouseDown = false;
    // save board when user is done editing
    this.saveInLocal(this.islandService.toString());
  }

  canvasMouseDown(event: MouseEvent) {
    this.mouseDown = true;
    this.updateScreenFromMouseEvent(event);
  }

  canvasTapDown(event: any) {
    this.mouseDown = true;
    this.updateScreenFromTapEvent(event);
  }

  canvasMouseMove(event: MouseEvent) {
    this.updateScreenFromMouseEvent(event);
  }

  canvasTapMove(event: TouchEvent) {
    this.updateScreenFromTapEvent(event);
  }

  private updateScreenFromMouseEvent(event: MouseEvent) {
    if (this.canvas) {
      const rect = this.canvas.getBoundingClientRect();
      const pixelX = event.clientX - rect.left;
      const pixelY = event.clientY - rect.top;
      this.updateScreen(pixelX, pixelY);
    }
  }

  private updateScreenFromTapEvent(event: TouchEvent) {
    if (this.canvas) {
      const rect = this.canvas.getBoundingClientRect();
      const pixelX = event.touches[0].clientX - rect.left;
      const pixelY = event.touches[0].clientY - rect.top;
      this.updateScreen(pixelX, pixelY);
    }
  }

  private updateScreen(pixelX: number, pixelY: number) {
    if (this.canvas && this.context) {
      const cols = this.islandService.getCols();
      const rows = this.islandService.getRows();
      const pixelsInCol = this.canvas.offsetWidth / cols;
      const pixelsInRow = this.canvas.offsetHeight / rows;
      const tileCol = Math.floor(pixelX / pixelsInCol);
      const tileRow = Math.floor(pixelY / pixelsInRow);

      // update the mouse locations
      this.mouseColumn = tileCol - 1;
      this.mouseRow = tileRow - 1;
      this.islandService.setCursorPosition(this.mouseColumn, this.mouseRow);
      if (tileCol > 0 && tileRow > 0
        && tileCol < cols - 1 && tileRow < rows - 1) {
        // update the col and row
        if (this.editingEnabled && this.mouseDown && this.selectedTileTypeService) {
          // only re-render if we change the map
          if (this.islandService.getStaticTile(tileCol, tileRow) !== this.selectedTileTypeService.selectedTileType) {
            this.islandService.setStaticTile(tileCol, tileRow, this.selectedTileTypeService.selectedTileType);
            this.islandService.render(this.context);
          }
        }
      } else {
        // off the island
        this.mouseColumn = null;
        this.mouseRow = null;
        this.mouseDown = false;
      }
    }
  }

  saveInLocal(val: any) {
    this.storage.set(Storage.Board, val);
  }

  hasCachedIsland() {
    const cachedIsland = this.storage.get(Storage.Board);
    if (cachedIsland) {
      return !(cachedIsland === this.islandService.toString());
    } else {
      return false;
    }
  }

  loadCachedIsland() {
    const island = this.storage.get(Storage.Board);
    this.islandService.genIslandFromString(island);
    this.redraw();
  }

  resetState() {
    this.islandService.resetJeroos();
    this.islandService.resetDynamicIsland();
    this.redraw();
  }
}
