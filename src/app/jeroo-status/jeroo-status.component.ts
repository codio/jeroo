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

import { AfterViewInit, Component, ElementRef, OnDestroy, QueryList, ViewChildren } from '@angular/core';
import { Subscription } from 'rxjs';
import { BytecodeInterpreterService } from '../bytecode-interpreter/bytecode-interpreter.service';
import { IslandService } from '../island.service';
import { Jeroo } from '../bytecode-interpreter/jeroo';

@Component({
  selector: 'app-jeroo-status',
  templateUrl: './jeroo-status.component.html',
  styleUrls: ['./jeroo-status.component.scss']
})
export class JerooStatusComponent implements AfterViewInit, OnDestroy {
  @ViewChildren('canvas') jerooIcons !: QueryList<any>;
  subscription: Subscription | null = null;

  constructor(public bytecodeService: BytecodeInterpreterService, private islandService: IslandService) {
  }

  ngAfterViewInit() {
    this.subscription = this.bytecodeService.jerooChange$
      .subscribe(() => {
        this.jerooIcons.forEach((item: ElementRef) => {
          const canvas = item.nativeElement as HTMLCanvasElement;
          const id = parseInt(canvas.id, 10);
          const jeroo = this.bytecodeService.getJerooAtIndex(id);
          this.renderJeroo(canvas, jeroo);
        });
      });
    this.jerooIcons.changes.subscribe((_) => {
      this.jerooIcons.forEach((jerooIcon: ElementRef) => {
        const canvas = jerooIcon.nativeElement as HTMLCanvasElement;
        const id = parseInt(canvas.id, 10);
        const jeroo = this.bytecodeService.getJerooAtIndex(id);
        this.renderJeroo(canvas, jeroo);
      });
    });
  }

  private renderJeroo(canvas: HTMLCanvasElement, jeroo: Jeroo) {
    canvas.width = this.islandService.tsize;
    canvas.height = this.islandService.tsize;
    canvas.style.width = `${this.islandService.tsize}px`;
    canvas.style.height = `${this.islandService.tsize}px`;
    const context = canvas.getContext('2d');

    if (context) {
      if (this.islandService.imageAtlas == null) {
        this.islandService.getTileAtlasObs().subscribe(imageAtlas => {
          this.islandService.renderJeroo(context, imageAtlas, jeroo, 0, 0);
        });
      } else {
        this.islandService.renderJeroo(context, this.islandService.imageAtlas, jeroo, 0, 0);
      }
    }
  }

  ngOnDestroy() {
    if (this.subscription) {
      this.subscription.unsubscribe();
    }
  }
}
