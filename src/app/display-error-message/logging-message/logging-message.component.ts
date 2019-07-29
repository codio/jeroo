import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-logging-message',
  styleUrls: ['./logging-message.component.scss'],
  templateUrl: './logging-message.component.html'
})
export class LoggingMessageComponent {

  @Input()
  message: string;

  constructor() { }
}
