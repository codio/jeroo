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

import { Injectable } from '@angular/core';

export class Message {}

export class LoggingMessage {
  constructor(public message: string) {}
}

export class CompilationErrorMessage {
  constructor(public compilationError: CompilationError) {}
}

export class RuntimeErrorMessage {
  constructor(public message: string, public pane_num: number, public line_num: number) {}
}

@Injectable({
  providedIn: 'root'
})
export class MessageService {
  messages: Message[] = [];

  addMessage(message: Message) {
    this.messages.push(message);
  }

  clear() {
    this.messages = [];
  }
}
