import { Component, OnInit } from '@angular/core';
import { MatDialog, MatDialogConfig } from '@angular/material';
import { MatrixDialogComponent } from '../matrix-dialog/matrix-dialog.component';
import { MatrixService } from '../matrix.service';

@Component({
  selector: 'app-jeroo-matrix',
  templateUrl: './jeroo-matrix.component.html',
  styleUrls: ['./jeroo-matrix.component.scss']
})
export class JerooMatrixComponent implements OnInit {

  // variables for component
  currentXLocation = 0;
  currentYLocation = 0;
  mouseDown = false;

  constructor(private dialog: MatDialog, public matrixService: MatrixService) { }

  // how to handle clicks from user
  onClick(event: any, row: number, column: number) {
      this.mouseDown = true;

      // make sure the user is not "off the island"
      if (this.currentXLocation !== this.matrixService.getMaxXSize() - 1 && this.currentYLocation !== this.matrixService.getMaxYSize() - 1
          && this.currentXLocation !== -1 && this.currentYLocation !== -1) {
            if (this.matrixService.getBoardValueAt(row, column) !== this.matrixService.getCurrentValue()) {
              this.matrixService.setBoardValueAt(row, column);
            }
      }
      // return false here will stop action of clicking and holding to drag an image around. Since we are dealing
      // with an array of images this will stop the browser from allowing the user to do that
      return false;
  }

  // when the mouse is released
  mouseUp() {
    this.mouseDown = false;
  }

  // each time a new matrix element is hovered over, check if the mouse is down
  // and report the current coordinates
  onMouseOver(event: any, row: number, column: number) {
    this.currentXLocation = column - 1;
    this.currentYLocation = row - 1;

    if (this.mouseDown === true) {
      this.onClick(event, row, column);
    }
  }

  // when the user selects a tile type at the top of the screen to edit tiles
  // on the matrix
  selectTile(tileType: string) {
    if (tileType === this.matrixService.getClearType()) {
      this.matrixService.drawBoard();
    } else {
      this.matrixService.setCurrentValue(tileType);
    }
    // returning false will prevent the user from clicking and holding a tile, while
    // being able to drag it around the screen
    return false;
  }

  // returns the percentage to scale each img to properly fit and scale to the div
  // it will be put into
  getPixel() {
    const percentValue = (90 / this.matrixService.getWidthSize());
    return (percentValue + '%');
  }

  // responsible for opening the dialogue and saving the information once it has been
  // closed
  openDialog() {
    const dialogConfig = new MatDialogConfig();

    dialogConfig.autoFocus = true;

    dialogConfig.data = {
      id: 1,
      xValue: this.matrixService.getWidthSize() - 2,
      yValue: this.matrixService.getHeightSize() - 2
    };

    const dialogRef = this.dialog.open(MatrixDialogComponent, dialogConfig);

    dialogRef.afterClosed().subscribe(
      data => { this.matrixService.setWidthSize(+data.xValue + +2), this.matrixService.setHeightSize(+data.yValue + +2); this.ngOnInit();
                this.matrixService.setMaxXSize(); this.matrixService.setMaxYSize(); },
    );

  }

  ngOnInit() {
    this.matrixService.drawBoard();
  }

}
