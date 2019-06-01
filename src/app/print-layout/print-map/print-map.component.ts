import { AfterViewInit, Component, ElementRef, ViewChild } from '@angular/core';
import { MatrixService } from 'src/app/matrix.service';
import { PrintService } from 'src/app/print.service';

@Component({
  selector: 'app-print-map',
  templateUrl: './print-map.component.html'
})
export class PrintMapComponent implements AfterViewInit {
  @ViewChild('canvas', { static: true }) canvasRef: ElementRef;
  private canvas: HTMLCanvasElement;
  private context: CanvasRenderingContext2D;

  constructor(private matrixService: MatrixService, private printService: PrintService) { }

  ngAfterViewInit() {
    this.canvas = this.canvasRef.nativeElement as HTMLCanvasElement;
    this.context = this.canvas.getContext('2d');
    this.canvas.width = window.innerWidth;
    this.canvas.height = window.innerHeight;

    const imageAtlas = this.matrixService.imageAtlas;
    if (!imageAtlas) {
      this.matrixService.getTileAtlasObs().subscribe(image => {
        this.renderTiles(image);
        setTimeout(() => this.printService.onDataReady());
      });
    } else {
      this.renderTiles(imageAtlas);
      setTimeout(() => this.printService.onDataReady());
    }
  }

  private renderTiles(image: HTMLImageElement) {
    for (let row = 0; row < this.matrixService.getRows(); row++) {
      for (let col = 0; col < this.matrixService.getCols(); col++) {
        const tile = this.matrixService.getStaticTile(col, row);
        if (tile !== null) {
          this.matrixService.renderTile(this.context, image, tile, col, row);
        }
      }
    }
  }
}
