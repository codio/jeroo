import { Component, Input } from '@angular/core';
import { RuntimeErrorMessage } from 'src/app/message.service';
import { CodeService, selectedTabToString, SelectedTab } from 'src/app/code.service';

@Component({
  selector: 'app-runtime-error-message',
  templateUrl: './runtime-error-message.component.html',
  styleUrls: ['./runtime-error-message.component.scss']
})
export class RuntimeErrorMessageComponent {
  @Input()
  runtimeErrorMessage: RuntimeErrorMessage;

  constructor(private codeService: CodeService) { }

  onPositionLinkClick(event: MouseEvent) {
    event.preventDefault();
    this.codeService.setCursorPosition({
      lnum: this.runtimeErrorMessage.line_num,
      cnum: 0,
      pane: this.runtimeErrorMessage.pane_num
    });
  }

  selectedTabToString(selectedTab: SelectedTab) {
    return selectedTabToString(selectedTab);
  }
}