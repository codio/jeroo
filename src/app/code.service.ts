import { Injectable } from '@angular/core';

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

@Injectable({
  providedIn: 'root'
})
export class CodeService {
  mainMethodCode = '';
  extensionMethodCode = '';
  selectedLanguage = SelectedLanguage.Java;
  prefrences: EditorPreferences = {
    fontSize: 12,
    colorTheme: Themes.Default
  };

  constructor() { }

  genCodeStr() {
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
    jerooCode += this.extensionMethodCode;
    jerooCode += '\n@@\n';
    jerooCode += this.mainMethodCode;
    return jerooCode;
  }

  loadCodeFromStr(code: string) {
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

    this.extensionMethodCode = extensionMethodCodeBuffer.trim();
    this.mainMethodCode = mainMethodCodeBuffer.trim();
  }
}