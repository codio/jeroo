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

import { Component, Input } from '@angular/core';
import { CodeService, SelectedTab, SelectedTabUtils } from 'src/app/code.service';
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
    return SelectedTabUtils.toString(selectedTab);
  }
}
