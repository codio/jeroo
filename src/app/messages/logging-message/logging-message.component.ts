import { Component, Input } from '@angular/core';
import { LoggingMessage } from 'src/app/message.service';

@Component({
  selector: 'app-logging-message',
  styleUrls: ['./logging-message.component.scss'],
  templateUrl: './logging-message.component.html'
})
export class LoggingMessageComponent {

  @Input()
  loggingMessage: LoggingMessage | null = null;

  constructor() { }
}
