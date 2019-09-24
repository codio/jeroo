import { AfterViewInit, Component, ElementRef, ViewChild } from '@angular/core';
import { IslandService } from 'src/app/island.service';
import { PrintService } from 'src/app/print.service';

@Component({
  selector: 'app-print-island',
  templateUrl: './print-island.component.html'
})
export class PrintIslandComponent implements AfterViewInit {
  @ViewChild('canvas', { static: true }) canvasRef: ElementRef | null = null;
  private canvas: HTMLCanvasElement | null = null;
  private context: CanvasRenderingContext2D | null = null;

  constructor(private islandService: IslandService, private printService: PrintService) { }

  ngAfterViewInit() {
    if (this.canvasRef) {
      this.canvas = this.canvasRef.nativeElement as HTMLCanvasElement;
      this.context = this.canvas.getContext('2d');
      this.canvas.width = window.innerWidth;
      this.canvas.height = window.innerHeight;

      const imageAtlas = this.islandService.imageAtlas;
      if (!imageAtlas) {
        this.islandService.getTileAtlasObs().subscribe(image => {
          this.renderTiles(image);
          setTimeout(() => this.printService.onDataReady());
        });
      } else {
        this.renderTiles(imageAtlas);
        setTimeout(() => this.printService.onDataReady());
      }
    }
  }

  private renderTiles(image: HTMLImageElement) {
    if (this.context) {
      for (let row = 0; row < this.islandService.getRows(); row++) {
        for (let col = 0; col < this.islandService.getCols(); col++) {
          const tile = this.islandService.getStaticTile(col, row);
          if (tile !== null) {
            this.islandService.renderTile(this.context, image, tile, col, row);
          }
        }
      }
    }
  }
}
