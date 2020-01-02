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
import { BehaviorSubject, Observable } from 'rxjs';

export enum SelectedLanguage {
  Java = 'java',
  Vb = 'vb',
  Python = 'python'
}

export enum Themes {
  Default = 'default',
  Darcula = 'darcula',
  Solarized = 'solarized ',
  Monakai = 'monokai',
  TheMattix = 'the-matrix',
  Neat = 'neat'
}

export interface EditorPreferences {
  fontSize: number;
  colorTheme: Themes;
}

export interface EditorCode {
  mainMethodCode: string;
  extensionsMethodCode: string;
}

export enum SelectedTab {
  Main = 0,
  Extensions = 1
}

export namespace SelectedTab {
  export function toString(selectedTab: SelectedTab) {
    switch (selectedTab) {
      case SelectedTab.Main: return 'Main';
      case SelectedTab.Extensions: return 'Extensions';
    }
  }
}

export interface Position {
  lnum: number;
  cnum: number;
  pane: SelectedTab;
}

@Injectable({
  providedIn: 'root'
})
export class CodeService {
  selectedLanguage = SelectedLanguage.Java;
  prefrences: EditorPreferences = {
    fontSize: 12,
    colorTheme: Themes.Default
  };
  private cursorPosition: BehaviorSubject<Position>;


  constructor() {
    this.cursorPosition = new BehaviorSubject<Position>({
      lnum: 0,
      cnum: 0,
      pane: SelectedTab.Main
    });
  }

  genCodeStr(code: EditorCode): string {
    let jerooCode = '';
    if (this.selectedLanguage === SelectedLanguage.Java) {
      jerooCode += '@Java\n';
    } else if (this.selectedLanguage === SelectedLanguage.Vb) {
      jerooCode += '@VB\n';
    } else if (this.selectedLanguage === SelectedLanguage.Python) {
      jerooCode += '@PYTHON\n';
    } else {
      throw new Error('Unsupported Language');
    }
    jerooCode += code.extensionsMethodCode;
    jerooCode += '\n@@\n';
    jerooCode += code.mainMethodCode;
    return jerooCode;
  }

  parseCodeFromStr(code: string): EditorCode {
    let mainMethodCodeBuffer = '';
    let extensionMethodCodeBuffer = '';
    let usingExtensionCodeBuffer = false;
    let lookingForHeader = true;

    code.split('\n').forEach(line => {
      if (lookingForHeader && line.startsWith('@')) {
        if (line === '@Java') {
          this.selectedLanguage = SelectedLanguage.Java;
        } else if (line === '@VB') {
          this.selectedLanguage = SelectedLanguage.Vb;
        } else if (line === '@PYTHON') {
          this.selectedLanguage = SelectedLanguage.Python;
        }
        lookingForHeader = false;
        usingExtensionCodeBuffer = true;
      } else if (usingExtensionCodeBuffer && line.startsWith('@@')) {
        usingExtensionCodeBuffer = false;
      } else {
        if (usingExtensionCodeBuffer) {
          extensionMethodCodeBuffer += line + '\n';
        } else {
          mainMethodCodeBuffer += line + '\n';
        }
      }
    });

    return {
      extensionsMethodCode: extensionMethodCodeBuffer.trim(),
      mainMethodCode: mainMethodCodeBuffer.trim()
    };
  }

  getCursorPosition(): Observable<Position> {
    return this.cursorPosition.asObservable();
  }

  setCursorPosition(newPosition: Position): void {
    this.cursorPosition.next(newPosition);
  }
}
