import { Injectable } from '@angular/core';
import { fromEvent } from 'rxjs';
import { map } from 'rxjs/operators';
import { Jeroo } from './jeroo';
import { stringToTileType, TileType, tileTypeToString } from './jerooTileType';

@Injectable({
    providedIn: 'root'
})
export class MatrixService {
    private rows = 26;
    private cols = 26;
    tsize = 28;
    private dynamicMap: TileType[] = [];
    imageAtlas: HTMLImageElement;
    private jeroos: Jeroo[] = [];
    // used to store the map before any runtime edits
    private staticMap: TileType[] = [];

    constructor() {
        this.resetMap();
        this.resetDynamicMap();
        this.resetJeroos();
    }

    resetJeroos() {
        this.jeroos = [];
        for (let row = 0; row < this.rows; row++) {
            for (let col = 0; col < this.cols; col++) {
                this.jeroos.push(null);
            }
        }
    }

    resetMap() {
        this.staticMap = [];
        for (let col = 0; col < this.cols; col++) {
            this.staticMap.push(TileType.Water);
        }
        for (let row = 0; row < this.rows - 2; row++) {
            this.staticMap.push(TileType.Water);
            for (let col = 0; col < this.cols - 2; col++) {
                this.staticMap.push(TileType.Grass);
            }
            this.staticMap.push(TileType.Water);
        }
        for (let col = 0; col < this.cols; col++) {
            this.staticMap.push(TileType.Water);
        }
    }

    resetDynamicMap() {
        this.dynamicMap = [];
        for (let col = 0; col < this.cols; col++) {
            for (let row = 0; row < this.rows; row++) {
                this.dynamicMap.push(null);
            }
        }
    }

    /**
     * @returns The number of rows in the matrix.
     */
    getRows() {
        return this.rows;
    }

    /**
     * @param rows The new number of rows in the matrix.
     */
    setRows(rows: number) {
        this.rows = rows;
    }

    /**
     * @returns The number of columns in the matrix.
     */
    getCols() {
        return this.cols;
    }

    /**
     * @param cols The number of columns in the matrix.
     */
    setCols(cols: number) {
        this.cols = cols;
    }

    getDynamicTile(col: number, row: number) {
        return this.dynamicMap[row * this.cols + col];
    }

    setDynamicTile(col: number, row: number, tile: TileType) {
        this.dynamicMap[row * this.cols + col] = tile;
    }

    getStaticTile(col: number, row: number) {
        return this.staticMap[row * this.cols + col];
    }

    setStaticTile(col: number, row: number, tile: TileType) {
        this.staticMap[row * this.cols + col] = tile;
    }

    /**
     * get a tile from both maps
     * prioritizes the dynamic map, but falls
     * back on the static map
     */
    getTile(col: number, row: number) {
        const dynamicTile = this.getDynamicTile(col, row);
        const staticTile = this.getStaticTile(col, row);
        if (dynamicTile !== null) {
            return dynamicTile;
        } else if (staticTile !== null) {
            return staticTile;
        } else {
            return null;
        }
    }

    getJeroo(col: number, row: number) {
        return this.jeroos[row * this.cols + col];
    }

    setJeroo(col: number, row: number, jeroo: Jeroo) {
        this.jeroos[row * this.cols + col] = jeroo;
    }

    isInBounds(col: number, row: number) {
        return col >= 0 && col < this.cols && row >= 0 && row < this.rows;
    }

    /**
     * @returns the size of a tile sprite in pixels.
     */
    getTsize() {
        return this.tsize;
    }

    /**
     * Renders the tilemap to a 2D rendering context.
     * @param context 2D rendering context.
     */
    render(context: CanvasRenderingContext2D) {
        if (!this.imageAtlas) {
            this.getTileAtlasObs().subscribe(imageAtlas => {
                this.renderTiles(context, imageAtlas);
                this.imageAtlas = imageAtlas;
            });
        } else {
            this.renderTiles(context, this.imageAtlas);
        }
    }

    private renderTiles(context: CanvasRenderingContext2D, imageAtlas: HTMLImageElement) {
        for (let row = 0; row < this.rows; row++) {
            for (let col = 0; col < this.cols; col++) {
                const jeroo = this.getJeroo(col, row);
                if (jeroo) {
                    const jerooCol = jeroo.getX();
                    const jerooRow = jeroo.getY();
                    this.renderJeroo(context, imageAtlas, jeroo, jerooCol, jerooRow);
                } else {
                    const tile = this.getTile(col, row);
                    if (tile !== null) {
                        this.renderTile(context, imageAtlas, tile, col, row);
                    }
                }
            }
        }
    }

    renderJeroo(context: CanvasRenderingContext2D, imageAtlas: HTMLImageElement, jeroo: Jeroo, col: number, row: number) {
        const jerooOffset = jeroo.getId() * 2 + 1;
        const directionOffset = jeroo.getDirection();
        if (jeroo.isInFlower()) {
            context.drawImage(
                imageAtlas,
                directionOffset * this.tsize,
                (jerooOffset + 1) * this.tsize,
                this.tsize,
                this.tsize,
                col * this.tsize,
                row * this.tsize,
                this.tsize,
                this.tsize
            );
        } else if (jeroo.isInWater()) {
            context.drawImage(
                imageAtlas,
                0,
                9 * this.tsize,
                this.tsize,
                this.tsize,
                col * this.tsize,
                row * this.tsize,
                this.tsize,
                this.tsize
            );
        } else if (jeroo.isInNet()) {
            context.drawImage(
                imageAtlas,
                1 * this.tsize,
                9 * this.tsize,
                this.tsize,
                this.tsize,
                col * this.tsize,
                row * this.tsize,
                this.tsize,
                this.tsize
            );
        } else if (jeroo.isInJeroo()) {
            context.drawImage(
                imageAtlas,
                2 * this.tsize,
                9 * this.tsize,
                this.tsize,
                this.tsize,
                col * this.tsize,
                row * this.tsize,
                this.tsize,
                this.tsize
            );
        } else {
            context.drawImage(
                imageAtlas,
                directionOffset * this.tsize,
                jerooOffset * this.tsize,
                this.tsize,
                this.tsize,
                col * this.tsize,
                row * this.tsize,
                this.tsize,
                this.tsize
            );
        }
    }

    renderTile(context: CanvasRenderingContext2D, imageAtlas: HTMLImageElement, tileType: TileType, col: number, row: number) {
        const offset = this.tileTypeToNumber(tileType);
        context.drawImage(
            imageAtlas,
            offset * this.tsize,
            0,
            this.tsize,
            this.tsize,
            col * this.tsize,
            row * this.tsize,
            this.tsize,
            this.tsize
        );
    }

    private tileTypeToNumber(tileType: TileType) {
        if (tileType === TileType.Grass) {
            return 0;
        } else if (tileType === TileType.Water) {
            return 1;
        } else if (tileType === TileType.Flower) {
            return 2;
        } else if (tileType === TileType.Net) {
            return 3;
        } else {
            throw new Error('Unknown TileType');
        }
    }

    getTileAtlasObs() {
        const image = new Image();
        const imageObservable = fromEvent(image, 'load');
        image.src = 'assets/images/JerooTilesSpritesheet.png';
        return imageObservable.pipe(map(() => image));
    }

    /**
     * Converts the current jeroo map into a string.
     * @returns The map in string form.
     */
    toString() {
        let mapContents = '';
        for (let row = 1; row < this.rows - 1; row++) {
            for (let col = 1; col < this.cols - 1; col++) {
                const tile = tileTypeToString(this.getStaticTile(col, row));
                mapContents += tile;
            }
            mapContents += '\n';
        }
        return mapContents;
    }


    /**
     * Set the current map to a map string.
     * @param s String of the map contents.
     */
    genMapFromString(s: string) {
        if (s !== '') {
            const lines = s.trim().split('\n');
            const rows = lines.length;
            const cols = lines[0].length;
            const oldRows = this.getRows();
            const oldCols = this.getCols();
            this.setRows(rows + 2);
            this.setCols(cols + 2);

            try {
                for (let col = 0; col < cols + 2; col++) {
                    this.setStaticTile(col, 0, TileType.Water);
                }
                for (let row = 1; row < rows + 1; row++) {
                    if (lines[row - 1].length !== cols) {
                        throw new Error('Jagged maps are not allowed');
                    }
                    this.setStaticTile(0, row, TileType.Water);
                    for (let col = 1; col < cols + 1; col++) {
                        const char = lines[row - 1].charAt(col - 1);
                        this.setStaticTile(col, row, stringToTileType(char));
                    }
                    this.setStaticTile(cols + 1, row, TileType.Water);
                }
                for (let col = 0; col < cols + 2; col++) {
                    this.setStaticTile(col, rows + 1, TileType.Water);
                }
            } catch (e) {
                // reset the rows and cols to their previous values
                // re-throw the exception
                this.setRows(oldRows);
                this.setCols(oldCols);
                throw e;
            }
        } else {
            this.setRows(0);
            this.setCols(0);
        }
    }
}
