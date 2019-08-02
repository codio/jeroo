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
