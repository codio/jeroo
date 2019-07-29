import { Component, Input } from '@angular/core';
import { CodeService, SelectedTab } from 'src/app/code.service';

@Component({
  selector: 'app-compilation-error-message',
  styleUrls: ['./compilation-error-message.component.scss'],
  templateUrl: './compilation-error-message.component.html'
})
export class CompilationErrorMessageComponent {
  @Input()
  error: CompilationError;

  constructor(private codeService: CodeService) { }

  onPositionLinkClick(e: MouseEvent) {
    e.preventDefault();
    this.codeService.setCursorPosition({
      lnum: this.error.lnum,
      cnum: this.error.cnum,
      pane: this.error.pane
    });
  }

  selectedTabToString(selectedTab: SelectedTab) {
    switch (selectedTab) {
      case SelectedTab.Main: return 'Main';
      case SelectedTab.Extensions: return 'Extensions';
    }
  }
}
