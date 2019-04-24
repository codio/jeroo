import { AfterViewInit, Component, ElementRef, OnDestroy, QueryList, ViewChildren } from '@angular/core';
import { Subscription } from 'rxjs';
import { BytecodeInterpreterService } from '../bytecode-interpreter.service';
import { MatrixService } from '../matrix.service';
import { Jeroo } from '../jeroo';

@Component({
    selector: 'app-jeroo-status',
    templateUrl: './jeroo-status.component.html',
    styleUrls: ['./jeroo-status.component.scss']
})
export class JerooStatusComponent implements AfterViewInit, OnDestroy {
    @ViewChildren('canvas') jerooIcons !: QueryList<any>;
    subscription: Subscription;

    constructor(public bytecodeService: BytecodeInterpreterService, private matrixService: MatrixService) {
    }

    ngAfterViewInit() {
        this.subscription = this.bytecodeService.jerooChange$
            .subscribe(jeroo => {
                const canvas: HTMLCanvasElement = this.jerooIcons.find((item: ElementRef, _index, _array) => {
                    const c = item.nativeElement as HTMLCanvasElement;
                    const id = parseInt(c.id, 10);
                    return id === jeroo.getId();
                }).nativeElement;
                this.renderJeroo(canvas, jeroo);
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
        canvas.width = this.matrixService.tsize;
        canvas.height = this.matrixService.tsize;
        canvas.style.width = `${this.matrixService.tsize}px`;
        canvas.style.height = `${this.matrixService.tsize}px`;
        const context = canvas.getContext('2d');

        if (this.matrixService.imageAtlas == null) {
            this.matrixService.getTileAtlasObs().subscribe(imageAtlas => {
                this.matrixService.renderJeroo(context, imageAtlas, jeroo, 0, 0);
            });
        } else {
            this.matrixService.renderJeroo(context, this.matrixService.imageAtlas, jeroo, 0, 0);
        }
    }

    ngOnDestroy() {
        this.subscription.unsubscribe();
    }
}
