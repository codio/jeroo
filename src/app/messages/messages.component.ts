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
