import { Injectable } from '@angular/core';
import { TileType } from './matrixConstants';
import { fromEvent } from 'rxjs';
import { map } from 'rxjs/operators';
import { Jeroo } from './jeroo';


@Injectable({
    providedIn: 'root'
})
export class MatrixService {

    private rows = 24;
    private cols = 24;
    private tsize = 28;
    private tiles: TileType[] = [];
    private imageAtlas: HTMLImageElement;
    private jeroos: Jeroo[] = [];

    constructor() {
        this.resetMap();
        this.resetJeroos();
    }

    public resetJeroos() {
        this.jeroos = [];
        for (let row = 0; row < this.rows; row++) {
            for (let col = 0; col < this.cols; col++) {
                this.jeroos.push(null);
            }
        }
    }

    /**
     * Resets the tile map to all grass
     */
    public resetMap() {
        this.tiles = [];
        for (let row = 0; row < this.rows; row++) {
            for (let col = 0; col < this.cols; col++) {
                this.tiles.push(TileType.Grass);
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

    /**
      * @param col The column of the tile.
      * @param row The row of the tile.
      * @returns the tile at the specified column and row.
      */
    getTile(col: number, row: number) {
        return this.tiles[row * this.cols + col];
    }

    /**
      * @param col The column of the tile.
      * @param row The row of the tile.
      * @param tile The tile type of the tile.
      */
    setTile(col: number, row: number, tile: TileType) {
        this.tiles[row * this.cols + col] = tile;
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
        if (this.imageAtlas == null) {
            this.getTileAtlasObs().subscribe(imageAtlas => {
                this.renderTiles(context, imageAtlas);
                this.imageAtlas = imageAtlas;
            });
        } else {
            this.renderTiles(context, this.imageAtlas);
        }
    }

    private renderTiles(context: CanvasRenderingContext2D, imageAtlas: HTMLImageElement) {
        // fill the top row with water
        for (let col = 0; col < this.cols + 2; col++) {
            this.renderTile(context, imageAtlas, TileType.Water, col, 0);
        }
        for (let row = 0; row < this.rows; row++) {
            // fill in the left water tile
            this.renderTile(context, imageAtlas, TileType.Water, 0, row + 1);
            for (let col = 0; col < this.cols; col++) {
                const jeroo = this.getJeroo(col, row);
                if (jeroo !== null) {
                    this.renderJeroo(context, imageAtlas, jeroo);
                } else {
                    const tile = this.getTile(col, row);
                    this.renderTile(context, imageAtlas, tile, col + 1, row + 1);
                }
            }
            // fill in the right water tile
            this.renderTile(context, imageAtlas, TileType.Water, this.cols + 1, row + 1);
        }
        // fill the bottom row with water
        for (let col = 0; col < this.cols + 2; col++) {
            this.renderTile(context, imageAtlas, TileType.Water, col, this.rows + 1);
        }
    }

    private renderJeroo(context: CanvasRenderingContext2D, imageAtlas: HTMLImageElement, jeroo: Jeroo) {
        const jerooOffset = jeroo.getId() + 1;
        const directionOffset = jeroo.getDirection();
        const col = jeroo.getX() + 1;
        const row = jeroo.getY() + 1;
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

    private renderTile(context: CanvasRenderingContext2D, imageAtlas: HTMLImageElement, tileType: TileType, col: number, row: number) {
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

    private getTileAtlasObs() {
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
        for (let row = 0; row < this.rows; row++) {
            for (let col = 0; col < this.cols; col++) {
                const tile = this.tileTypeToString(this.getTile(col, row));
                mapContents += tile;
            }
            mapContents += '\n';
        }
        return mapContents;
    }

    /**
      * Converts a TileType to a string
      * @param tileType tileType to convert
      * @returns string representation of a TileType
      */
    tileTypeToString(tileType: TileType) {
        if (tileType === TileType.Grass) {
            return '.';
        } else if (tileType === TileType.Water) {
            return 'W';
        } else if (tileType === TileType.Flower) {
            return 'F';
        } else if (tileType === TileType.Net) {
            return 'N';
        } else {
            throw new Error('Invalid TileType');
        }
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
            this.setRows(rows);
            this.setCols(cols);

            try {
                for (let row = 0; row < rows; row++) {
                    if (lines[row].length !== cols) {
                        throw new Error('Jagged maps are not allowed');
                    }
                    for (let col = 0; col < cols; col++) {
                        const char = lines[row].charAt(col);
                        this.setTile(col, row, this.stringToTileType(char));
                    }
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

    /**
      * Convert a character to a TileType.
      * @param char character to convert.
      * @returns Converted tile.
      */
    stringToTileType(char: string) {
        if (char === '.') {
            return TileType.Grass;
        } else if (char === 'W') {
            return TileType.Water;
        } else if (char === 'F') {
            return TileType.Flower;
        } else if (char === 'N') {
            return TileType.Net;
        } else {
            throw new Error('Invalid TileType in map');
        }
    }
}
