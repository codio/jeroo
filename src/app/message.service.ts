import { Injectable } from '@angular/core';

export interface Message {
  loggingMessage?: string;
  compilationError?: CompilationError;
}

@Injectable({
  providedIn: 'root'
})
export class MessageService {
  messages: Message[] = [];

  addErrorMessage(message: string) {
    this.messages.push({ loggingMessage: message });
  }

  addCompilationError(compilationError: CompilationError) {
    this.messages.push({ compilationError: compilationError });
  }

  isMessageCompilationError(message: Message) {
    return message.compilationError !== undefined;
  }

  isMessageLoggingMessage(message: Message) {
    return message.loggingMessage !== undefined;
  }

  clear() {
    this.messages = [];
  }
}
