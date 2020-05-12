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
import { LiveAnnouncer } from '@angular/cdk/a11y';
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
  selectionRow = 0;
  selectionColumn = 0;
  private canvas: HTMLCanvasElement | null = null;
  private context: CanvasRenderingContext2D | null = null;
  private mouseDown = false;
  private toggleView = true;
  private toggleKeyboard = false;
  private lastIslandEdit = [this.islandService.toString()];
  private editType = 0;
  private areaCornerSelected = false;
  private cornerRow = 0;
  private cornerCol = 0;
  private filling = false;
  constructor(private islandService: IslandService, private liveAnnouncer: LiveAnnouncer, private dialog: MatDialog,
    public bytecodeService: BytecodeInterpreterService,
    private selectedTileTypeService: SelectedTileTypeService,
    @Inject(LOCAL_STORAGE) private storage: WebStorageService
  ) { }


  getToggleView() {
    return this.toggleView;
  }

  setToggleView() {

    this.toggleView = !this.toggleView;
  }

  getToggleKeyboard() {
    return this.toggleKeyboard;
  }

  setToggleKeyboard() {

    this.toggleKeyboard = !this.toggleKeyboard;
    if (this.toggleKeyboard) {
      if (this.jerooGameCanvas) {
        this.jerooGameCanvas.nativeElement.focus();
        this.liveAnnouncer.announce('Keyboard controls enabled');
      }
    } else {
      this.liveAnnouncer.announce('Keyboard controls disabled');
    }
  }

  cursorUp() {
    if (this.selectionRow > 0) {
      this.selectionRow -= 1;
      this.liveAnnouncer.announce('Cursor set to ' + this.selectionColumn + ' ' + this.selectionRow);
      this.islandService.setSelectionPosition(this.selectionColumn, this.selectionRow);
      if (this.context) {
        this.islandService.render(this.context);
      }
    }
  }
  cursorDown() {
    if (this.selectionRow < this.islandService.getRows() - 3) {
      this.selectionRow += 1;
      this.liveAnnouncer.announce('Cursor set to ' + this.selectionColumn + ' ' + this.selectionRow);
      this.islandService.setSelectionPosition(this.selectionColumn, this.selectionRow);
      if (this.context) {
        this.islandService.render(this.context);
      }

    }
  }
  cursorLeft() {
    if (this.selectionColumn > 0) {
      this.selectionColumn -= 1;
      this.liveAnnouncer.announce('Cursor set to ' + this.selectionColumn + ' ' + this.selectionRow);
      this.islandService.setSelectionPosition(this.selectionColumn, this.selectionRow);
      if (this.context) {
        this.islandService.render(this.context);
      }
    }
  }

  cursorRight() {
    if (this.selectionColumn < this.islandService.getCols() - 3) {
      this.selectionColumn += 1;
      this.liveAnnouncer.announce('Cursor set to ' + this.selectionColumn + ' ' + this.selectionRow);
      this.islandService.setSelectionPosition(this.selectionColumn, this.selectionRow);
      if (this.context) {
        this.islandService.render(this.context);
      }
    }
  }
  cursorEnter() {
    if (this.canvas && this.context) { // If the canvas and context are initialized
      if (this.editingEnabled && this.selectedTileTypeService) { // If editing is enabled and the selectedTileTypeService is initialized
        if (this.editType === 0) { // If the editor is in single tile mode
          if (this.islandService.getStaticTile(this.selectionColumn + 1, this.selectionRow + 1)
            !== this.selectedTileTypeService.selectedTileType) { // If the tile selected is different from the tile to be edited
            this.islandService.setStaticTile(this.selectionColumn + 1, this.selectionRow + 1,
              this.selectedTileTypeService.selectedTileType);
            this.islandService.render(this.context);
          }
        } else if (this.editType === 1) {
          if (this.areaCornerSelected) {
            this.lastIslandEdit.push(this.islandService.toString());
            const top = this.cornerRow > this.selectionRow ? this.selectionRow : this.cornerRow;
            const bottom = this.cornerRow < this.selectionRow ? this.selectionRow : this.cornerRow;
            const left = this.cornerCol > this.selectionColumn ? this.selectionColumn : this.cornerCol;
            const right = this.cornerCol < this.selectionColumn ? this.selectionColumn : this.cornerCol;
            for (let row = top; row <= bottom; row++) {
              for (let col = left; col <= right; col++) {
                this.islandService.setStaticTile(col + 1, row + 1,
                  this.selectedTileTypeService.selectedTileType);
              }
            }
            this.islandService.render(this.context);
            this.areaCornerSelected = false;
          } else {
            this.cornerCol = this.selectionColumn;
            this.cornerRow = this.selectionRow;
            this.areaCornerSelected = true;
          }
        } else if (this.editType === 2) {
          if (!this.filling) {
            this.lastIslandEdit.push(this.islandService.toString());
            this.floodFill(this.selectionRow + 1, this.selectionColumn + 1);
            this.islandService.render(this.context);
          }

        }
      }
    }
  }
  setEditType(tileTypeIndex: number) {
    this.editType = tileTypeIndex;
  }
  undo() {
    if (this.canvas && this.context) {

      const lastIsland = this.lastIslandEdit.pop();
      if (lastIsland !== undefined) {
        this.islandService.genIslandFromString(lastIsland);

      }

      this.islandService.render(this.context);
    }
  }

  floodFill(tileRow: number, tileCol: number) {
    this.filling = true;
    const cols = this.islandService.getCols();
    const rows = this.islandService.getRows();
    const queue = new Array<CoordinateType>();
    if (!(tileRow === undefined || tileCol === undefined)) {
      queue.push({ row: tileRow, col: tileCol });
    }

    const target = this.islandService.getStaticTile(tileCol, tileRow);
    if (target === this.selectedTileTypeService.selectedTileType) {
      this.filling = false;
      return;
    }
    if (tileCol > 0 && tileRow > 0 && tileCol < cols - 1 && tileRow < rows - 1) {
      if (this.islandService.getStaticTile(tileCol, tileRow) === target) {
        this.islandService.setStaticTile(tileCol, tileRow, this.selectedTileTypeService.selectedTileType);
      }

    }
    while (queue.length !== 0) {
      let newCol = 0;
      let newRow = 0;
      const newThing = queue.shift();
      if (newThing !== undefined) {
        if (!(newThing.col === undefined || newThing.row === undefined)) {
          newCol = newThing.col;
          newRow = newThing.row;
        }
      }

      if (!(newCol === undefined || newRow === undefined)) {
        if (newCol + 1 > 0 && newRow > 0 && newCol + 1 < cols - 1 && newRow < rows - 1) {
          if (this.islandService.getStaticTile(newCol + 1, newRow) === target) {
            this.islandService.setStaticTile(newCol + 1, newRow, this.selectedTileTypeService.selectedTileType);
            queue.push({ row: newRow, col: newCol + 1 });
          }

        }

        if (newCol > 0 && newRow - 1 > 0 && newCol < cols - 1 && newRow - 1 < rows - 1) {
          if (this.islandService.getStaticTile(newCol, newRow - 1) === target) {
            this.islandService.setStaticTile(newCol, newRow - 1, this.selectedTileTypeService.selectedTileType);
            queue.push({ row: newRow - 1, col: newCol });
          }

        }

        if (newCol - 1 > 0 && newRow > 0 && newCol - 1 < cols - 1 && newRow < rows - 1) {
          if (this.islandService.getStaticTile(newCol - 1, newRow) === target) {
            this.islandService.setStaticTile(newCol - 1, newRow, this.selectedTileTypeService.selectedTileType);
            queue.push({ row: newRow, col: newCol - 1 });
          }

        }

        if (newCol > 0 && newRow + 1 > 0 && newCol < cols - 1 && newRow + 1 < rows - 1) {
          if (this.islandService.getStaticTile(newCol, newRow + 1) === target) {
            this.islandService.setStaticTile(newCol, newRow + 1, this.selectedTileTypeService.selectedTileType);
            queue.push({ row: newRow + 1, col: newCol });
          }

        }
      }

    }
    this.filling = false;
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


  getJerooNameOnTile(col: number, row: number) {
    const jeroo = this.islandService.getJeroo(col, row);
    if (jeroo !== null) {
      return 'Jeroo' + this.bytecodeService.jerooMap[jeroo.getId()];
    } else {
      return null;
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
    if (!(this.mouseDown && this.editType === 1)) {
      this.updateScreenFromMouseEvent(event);
    }

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

      if (tileCol > 0 && tileRow > 0
        && tileCol < cols - 1 && tileRow < rows - 1) {
        // update the col and row
        if (this.mouseDown) {
          this.selectionColumn = tileCol - 1;
          this.selectionRow = tileRow - 1;
          this.islandService.setSelectionPosition(this.selectionColumn, this.selectionRow);
          this.islandService.render(this.context);
        }

        if (this.editingEnabled && this.mouseDown && this.selectedTileTypeService) {
          // only re-render if we change the map

          if (this.editType === 0) {
            if (this.islandService.getStaticTile(tileCol, tileRow) !== this.selectedTileTypeService.selectedTileType) {
              this.lastIslandEdit.push(this.islandService.toString());
              this.islandService.setStaticTile(tileCol, tileRow, this.selectedTileTypeService.selectedTileType);
              this.islandService.render(this.context);
            }
          } else if (this.editType === 1) {
            if (this.areaCornerSelected) {
              this.lastIslandEdit.push(this.islandService.toString());
              const top = this.cornerRow > this.selectionRow ? this.selectionRow : this.cornerRow;
              const bottom = this.cornerRow < this.selectionRow ? this.selectionRow : this.cornerRow;
              const left = this.cornerCol > this.selectionColumn ? this.selectionColumn : this.cornerCol;
              const right = this.cornerCol < this.selectionColumn ? this.selectionColumn : this.cornerCol;
              for (let row = top; row <= bottom; row++) {
                for (let col = left; col <= right; col++) {
                  this.islandService.setStaticTile(col + 1, row + 1,
                    this.selectedTileTypeService.selectedTileType);
                }
              }
              this.islandService.render(this.context);
              this.areaCornerSelected = false;
            } else {
              this.cornerCol = this.selectionColumn;
              this.cornerRow = this.selectionRow;
              this.areaCornerSelected = true;
            }
          } else if (this.editType === 2) {
            if (!this.filling) {
              this.lastIslandEdit.push(this.islandService.toString());
              this.floodFill(this.selectionRow + 1, this.selectionColumn + 1);
              this.islandService.render(this.context);
            }

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
export interface CoordinateType { col: number; row: number; }
