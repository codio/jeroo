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

import { Injectable } from '@angular/core';
import { fromEvent } from 'rxjs';
import { map } from 'rxjs/operators';
import { Jeroo } from './bytecode-interpreter/jeroo';
import { TileType } from './tileType';

@Injectable({
  providedIn: 'root'
})
export class IslandService {
  private rows = 26;
  private cols = 26;
  tsize = 28;
  private dynamicTileMap: (TileType | null)[] = [];
  imageAtlas: HTMLImageElement | null = null;
  private jeroos: (Jeroo | null)[] = [];
  // used to store the map before any runtime edits
  private staticTileMap: TileType[] = [];

  constructor() {
    this.resetIsland();
    this.resetDynamicIsland();
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

  resetIsland() {
    this.staticTileMap = [];
    for (let col = 0; col < this.cols; col++) {
      this.staticTileMap.push(TileType.Water);
    }
    for (let row = 0; row < this.rows - 2; row++) {
      this.staticTileMap.push(TileType.Water);
      for (let col = 0; col < this.cols - 2; col++) {
        this.staticTileMap.push(TileType.Grass);
      }
      this.staticTileMap.push(TileType.Water);
    }
    for (let col = 0; col < this.cols; col++) {
      this.staticTileMap.push(TileType.Water);
    }
  }

  resetDynamicIsland() {
    this.dynamicTileMap = [];
    for (let col = 0; col < this.cols; col++) {
      for (let row = 0; row < this.rows; row++) {
        this.dynamicTileMap.push(null);
      }
    }
  }

  /**
   * @returns The number of rows in the island.
   */
  getRows() {
    return this.rows;
  }

  /**
   * @param rows The new number of rows in the island.
   */
  setRows(rows: number) {
    this.rows = rows;
  }

  /**
   * @returns The number of columns in the island.
   */
  getCols() {
    return this.cols;
  }

  /**
   * @param cols The number of columns in the island.
   */
  setCols(cols: number) {
    this.cols = cols;
  }

  getDynamicTile(col: number, row: number) {
    return this.dynamicTileMap[row * this.cols + col];
  }

  setDynamicTile(col: number, row: number, tile: TileType) {
    this.dynamicTileMap[row * this.cols + col] = tile;
  }

  getStaticTile(col: number, row: number) {
    return this.staticTileMap[row * this.cols + col];
  }

  setStaticTile(col: number, row: number, tile: TileType) {
    this.staticTileMap[row * this.cols + col] = tile;
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

  setJeroo(col: number, row: number, jeroo: Jeroo | null) {
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
        const tile = this.getStaticTile(col, row);
        mapContents += tile;
      }
      mapContents += '\n';
    }
    return mapContents;
  }


  /**
   * Set the current island to a map string.
   * @param s String of the map contents.
   */
  genIslandFromString(s: string) {
    if (s !== '') {
      const lines = s.trim().split('\n');
      const rows = lines.length;
      const cols = lines[0].length;
      const oldRows = this.getRows();
      const oldCols = this.getCols();
      this.setRows(rows + 2);
      this.setCols(cols + 2);

      this.resetJeroos();
      this.resetIsland();
      this.resetDynamicIsland();

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
            const char = TileType.stringToTileType(lines[row - 1].charAt(col - 1));
            this.setStaticTile(col, row, char);
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
