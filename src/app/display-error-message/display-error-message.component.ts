import { Component } from '@angular/core';
import { MessageService } from '../message.service';

@Component({
    selector: 'app-display-error-message',
    templateUrl: './display-error-message.component.html',
    styleUrls: ['./display-error-message.component.scss']
})
export class DisplayErrorMessageComponent {
    constructor(public messageService: MessageService) { }
}
