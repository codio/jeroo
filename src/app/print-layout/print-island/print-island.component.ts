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
