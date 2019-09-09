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

export function selectedTabToString(selectedTab: SelectedTab) {
  switch (selectedTab) {
    case SelectedTab.Main: return 'Main';
    case SelectedTab.Extensions: return 'Extensions';
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
