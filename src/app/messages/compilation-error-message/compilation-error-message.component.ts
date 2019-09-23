import { Component, Input } from '@angular/core';
import { CodeService, SelectedTab } from 'src/app/code.service';
import { CompilationErrorMessage } from 'src/app/message.service';

@Component({
  selector: 'app-compilation-error-message',
  styleUrls: ['./compilation-error-message.component.scss'],
  templateUrl: './compilation-error-message.component.html'
})
export class CompilationErrorMessageComponent {
  @Input()
  compilationErrorMessage: CompilationErrorMessage | null = null;

  constructor(private codeService: CodeService) { }

  onPositionLinkClick(e: MouseEvent) {
    e.preventDefault();
    if (this.compilationErrorMessage) {
      this.codeService.setCursorPosition({
        lnum: this.compilationErrorMessage.compilationError.lnum,
        cnum: this.compilationErrorMessage.compilationError.cnum,
        pane: this.compilationErrorMessage.compilationError.pane
      });
    }
  }

  selectedTabToString(selectedTab: SelectedTab) {
    return SelectedTab.toString(selectedTab);
  }
}
