import { Component, ViewChildren, QueryList, AfterViewInit, ElementRef } from '@angular/core';
import { MessageService } from '../message.service';

@Component({
    selector: 'app-display-error-message',
    templateUrl: './display-error-message.component.html',
    styleUrls: ['./display-error-message.component.scss']
})
export class DisplayErrorMessageComponent implements AfterViewInit {
    @ViewChildren('p') errorMessages !: QueryList<any>;
    @ViewChildren('div') divs !: QueryList<any>;

    constructor(public messageService: MessageService) { }

    ngAfterViewInit() {
        this.errorMessages.changes.subscribe((_) => {
            this.divs.forEach((divElementRef: ElementRef) => {
                const div = divElementRef.nativeElement;
                div.scrollTop = div.scrollHeight;
            });
        });
    }
}
