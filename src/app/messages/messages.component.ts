import { Component, ViewChildren, QueryList, AfterViewInit, ElementRef } from '@angular/core';
import { MessageService, Message, LoggingMessage, CompilationErrorMessage, RuntimeErrorMessage } from '../message.service';

@Component({
  selector: 'app-messages',
  templateUrl: './messages.component.html',
  styleUrls: ['./messages.component.scss']
})
export class MessagesComponent implements AfterViewInit {
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

  messageIsLoggingMessage(message: Message) {
    return message instanceof LoggingMessage;
  }

  messageIsRuntimeErrorMessage(message: Message) {
    return message instanceof RuntimeErrorMessage;
  }

  messageIsCompilationErrorMessage(message: Message) {
    return message instanceof CompilationErrorMessage;
  }
}
