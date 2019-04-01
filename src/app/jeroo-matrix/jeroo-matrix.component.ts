import { Component, ViewChild, ElementRef, AfterViewInit, Inject } from '@angular/core';
import { MatrixService } from '../matrix.service';
import { TileType } from '../matrixConstants';
import { MatDialog, MatDialogConfig } from '@angular/material';
import { MatrixDialogComponent } from '../matrix-dialog/matrix-dialog.component';
import { LOCAL_STORAGE, WebStorageService } from 'angular-webstorage-service';

@Component({
    selector: 'app-jeroo-matrix',
    templateUrl: './jeroo-matrix.component.html',
    styleUrls: ['./jeroo-matrix.component.scss']
})
export class JerooMatrixComponent implements AfterViewInit {
    @ViewChild('jerooGameCanvas') jerooGameCanvas: ElementRef;

    private canvas: HTMLCanvasElement;
    private context: CanvasRenderingContext2D;
    private mouseDown = false;
    private selectedTileType: TileType = null;
    private boardCache = 'board';
    mouseRow: number = null;
    mouseColumn: number = null;
    editingEnabled = true;

    constructor(private matrixService: MatrixService, private dialog: MatDialog,
        @Inject(LOCAL_STORAGE) private storage: WebStorageService) { }

    ngAfterViewInit() {
        // check if something has been stored in the cache to load if it has
        if (this.storage.get(this.boardCache) !== null) {
            this.matrixService.genMapFromString(this.storage.get(this.boardCache));
        }
        this.canvas = this.jerooGameCanvas.nativeElement as HTMLCanvasElement;
        this.context = this.canvas.getContext('2d');
        this.canvas.width = this.matrixService.getTsize() * (this.matrixService.getCols());
        this.canvas.height = this.matrixService.getTsize() * (this.matrixService.getRows());
        this.matrixService.render(this.context);
    }

    openDialog() {
        const dialogConfig = new MatDialogConfig();
        dialogConfig.autoFocus = true;
        dialogConfig.data = {
            xValue: this.matrixService.getCols() - 2,
            yValue: this.matrixService.getRows() - 2
        };

        const dialogRef = this.dialog.open(MatrixDialogComponent, dialogConfig);
        dialogRef.afterClosed().subscribe(data => {
            if (this.editingEnabled) {
                this.matrixService.setCols(+data.xValue + 2);
                this.matrixService.setRows(+data.yValue + 2);
                this.matrixService.resetMap();
                this.redraw();
            }
        });
    }

    redraw() {
        this.context.clearRect(0, 0,
            this.canvas.width,
            this.canvas.height
        );
        this.canvas.width = this.matrixService.getTsize() * (this.matrixService.getCols());
        this.canvas.height = this.matrixService.getTsize() * (this.matrixService.getRows());
        // if the board has been resized save into cache
        this.saveInLocal(this.boardCache, this.matrixService.toString());
        this.matrixService.render(this.context);
    }

    clearMap() {
        if (this.editingEnabled) {
            this.matrixService.resetMap();
            // if the board is cleared, also save into service incase the size has been changed
            this.saveInLocal(this.boardCache, this.matrixService.toString());
            this.matrixService.render(this.context);
        }
    }

    getCanvas() {
        return this.canvas;
    }

    getContext() {
        return this.context;
    }

    selectedTileTypeChange(tileType: string) {
        this.selectedTileType = this.tileTypeToString(tileType);
    }

    private tileTypeToString(tileType: string) {
        if (tileType === 'grass') {
            return TileType.Grass;
        } else if (tileType === 'water') {
            return TileType.Water;
        } else if (tileType === 'flower') {
            return TileType.Flower;
        } else if (tileType === 'net') {
            return TileType.Net;
        } else {
            throw new Error('Unknown TileType');
        }
    }

    canvasGestureUp() {
        this.mouseDown = false;
        // save board when user is done editing
        this.saveInLocal(this.boardCache, this.matrixService.toString());
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

    canvasTapMove(event: any) {
        this.updateScreenFromTapEvent(event);
    }

    // having a hammerjs action bound to a function will prevent the screen from scrolling while
    // being on the canvas on mobile devices
    disableScrolling() {

    }

    private updateScreenFromMouseEvent(event: MouseEvent) {
        const rect = this.canvas.getBoundingClientRect();
        // bitwise or is the same as casting a float to a number
        const pixelX = (event.clientX - rect.left) | 0;
        const pixelY = (event.clientY - rect.top) | 0;
        this.updateScreen(pixelX, pixelY);
    }

    private updateScreenFromTapEvent(event: TouchEvent) {
        const rect = this.canvas.getBoundingClientRect();
        const pixelX = (event.touches[0].clientX - rect.left) | 0;
        const pixelY = (event.touches[0].clientY - rect.top) | 0;
        this.updateScreen(pixelX, pixelY);
    }

    private updateScreen(pixelX: number, pixelY: number) {
        const cols = this.matrixService.getCols();
        const rows = this.matrixService.getRows();
        const pixelsInCol = this.matrixService.getTsize();
        const pixelsInRow = this.matrixService.getTsize();
        const tileCol = ((pixelX / pixelsInCol) | 0);
        const tileRow = ((pixelY / pixelsInRow) | 0);

        // update the mouse locations
        this.mouseColumn = tileCol;
        this.mouseRow = tileRow;

        if (tileCol >= 0 && tileRow >= 0
            && tileCol < cols - 2 && tileRow < rows - 2) {
            // update the col and row
            if (this.editingEnabled && this.mouseDown && this.selectedTileType !== null) {
                // only re-render if we change the map
                if (this.matrixService.getTile(tileCol, tileRow) !== this.selectedTileType) {
                    this.matrixService.setTile(tileCol, tileRow, this.selectedTileType);
                    this.matrixService.render(this.context);
                }
            }
        } else {
            // off the map
            this.mouseColumn = null;
            this.mouseRow = null;
            this.mouseDown = false;
        }
    }

    saveInLocal(key, val): void {
        this.storage.set(key, val);
    }

    enableEditing() {
        this.editingEnabled = true;
    }

    disableEditing() {
        this.editingEnabled = false;
    }
}
