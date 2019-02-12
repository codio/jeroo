import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class MatrixService {

  matrixHolder = [[]];

  currentValue = 'W';

  widthSize = 26;
  heightSize = 26;
  maxXSize = this.widthSize - 1;
  maxYSize = this.heightSize - 1;

  waterType = 'W';
  grassType = 'G';
  flowerType = 'F';
  netType = 'N';
  clearType = 'C';

  constructor() { }

  // create a board with a given size, and set it to the default values
  // (water on top/sides, grass everywhere else)
  generateBoard(xSize: number, ySize: number) {
    const arr = [];

    for (let row = 0; row < ySize; row++) {
      arr[row] = [];
      for (let column = 0; column < xSize; column++) {
        // if row == 0 or max use water OR if column == 0 or max
        if (row === 0 || row === (ySize - 1) || column === 0 || column === (xSize - 1)) {
          arr[row][column] = this.waterType;
        } else {
          arr[row][column] = this.grassType;
        }
      }
    }

    this.matrixHolder = arr;

  }

  drawBoard() {
    this.generateBoard(this.widthSize, this.heightSize);
  }

  // getters and setters for variables
  getMatrix() {
    return this.matrixHolder;
  }

  setWidthSize(wSize: number) {
    this.widthSize = wSize;
  }

  getWidthSize() {
    return this.widthSize;
  }

  setHeightSize(hSize: number) {
    this.heightSize = hSize;
  }

  getHeightSize() {
    return this.heightSize;
  }

  setMaxXSize() {
    this.maxXSize = this.widthSize - 1;
  }

  getMaxXSize() {
    return this.maxXSize;
  }

  setMaxYSize() {
    this.maxYSize = this.heightSize - 1;
  }

  getMaxYSize() {
    return this.maxYSize;
  }

  setCurrentValue(newValue: string) {
    switch (newValue) {
      case this.waterType: {
        this.currentValue = this.waterType;
        break;
      }
      case this.grassType: {
        this.currentValue = this.grassType;
        break;
      }
      case this.netType: {
        this.currentValue = this.netType;
        break;
      }
      case this.flowerType: {
        this.currentValue = this.flowerType;
        break;
      }
    }
  }

  getCurrentValue() {
    return this.currentValue;
  }

  getWaterType() {
    return this.waterType;
  }

  getGrassType() {
    return this.grassType;
  }

  getFlowerType() {
    return this.flowerType;
  }

  getNetType() {
    return this.netType;
  }

  getClearType() {
    return this.clearType;
  }

  getBoardValueAt(row: number, column: number) {
    return this.matrixHolder[row][column];
  }

  setBoardValueAt(row: number, column: number) {
    this.matrixHolder[row][column] = this.currentValue;
  }
  // getters and setters for variables

}
