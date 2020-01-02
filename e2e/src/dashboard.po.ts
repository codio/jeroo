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

import { browser, by, element } from 'protractor';

export class DashboardPage {

  navigateTo() {
    return browser.get('/dashboard');
  }

  writeToCodeMirror(incomingText: string) {
    browser.executeScript(
      `var editor = document.getElementsByClassName('CodeMirror')[0].CodeMirror;editor.setValue('${incomingText}');`
    );
  }

  getCodeMirrorTest() {
    return browser.executeScript(
      `var editor = document.getElementsByClassName('CodeMirror')[0].CodeMirror; return editor.getValue();`
    ) as Promise<String>;
  }

  setIslandSize(cols: number, rows: number) {
    this.getIslandEditMenu().click();
    this.getChangeIslandSize().click();
    this.getColValueInput().clear();
    this.getColValueInput().sendKeys(`${cols}`);
    this.getRowValueInput().clear();
    this.getRowValueInput().sendKeys(`${rows}`);
    this.getSubmitIslandDialogButton().click();
    this.getYesWarningButton().click();
  }

  getRunButton() {
    return element(by.id('runButton'));
  }

  getRunContinousButton() {
    return element(by.id('runContiniousButton'));
  }

  getPauseButton() {
    return element(by.id('pauseButton'));
  }

  getStopButton() {
    return element(by.id('stopButton'));
  }

  getSpeedMenu() {
    return element(by.id('runSpeedMenu'));
  }

  getSpeed6() {
    return element(by.id('speed6Btn'));
  }

  getIslandEditMenu() {
    return element(by.id('islandEditMenu'));
  }

  getNewIslandMenuItem() {
    return element(by.id('newIslandMenuItem'));
  }

  getChangeIslandSize() {
    return element(by.id('changeIslandSize'));
  }

  getCloseIslandDialogButton() {
    return element(by.id('closeIslandDialogButton'));
  }

  getSubmitIslandDialogButton() {
    return element(by.id('submitIslandDialogButton'));
  }

  getColValueInput() {
    return element(by.id('colValueInput'));
  }

  getRowValueInput() {
    return element(by.id('rowValueInput'));
  }

  getYesWarningButton() {
    return element(by.id('yesWarningButton'));
  }

  getNoWarningButton() {
    return element(by.id('noWarningButton'));
  }

  getMainEditorTab() {
    return element(by.id('mat-tab-label-0-0'));
  }

  getExtensionEditorTab() {
    return element(by.id('mat-tab-label-0-1'));
  }

  getLanguageSelection() {
    return element(by.id('mat-select-0'));
  }

  getJavaLanguage() {
    return element(by.id('mat-option-0'));
  }

  getVbLanguage() {
    return element(by.id('mat-option-1'));
  }

  getPythonLanguage() {
    return element(by.id('mat-option-2'));
  }

  // gets the last message in the window
  getFinalMessage() {
    return element(by.className('error-window')).all(by.className('ng-star-inserted')).last();
  }

  // identifier is 0, 1, 2, 3 based on when it was initialized
  getJerooName(identifier: string) {
    return element(by.id('name' + identifier));
  }

  getJerooFlowers(identifier: string) {
    return element(by.id('flowers' + identifier));
  }

  getImportProjectDialogBtn() {
    return element(by.id('importProjectBtn'));
  }

  getDontImportProjectDialogBtn() {
    return element(by.id('dontImportProjectBtn'));
  }

  async getIslandSize() {
    this.getIslandEditMenu().click();
    this.getChangeIslandSize().click();
    const numCols = parseInt(await this.getColValueInput().getAttribute('value'), 10);
    const numRows = parseInt(await this.getRowValueInput().getAttribute('value'), 10);
    this.getCloseIslandDialogButton().click();
    return { cols: numCols, rows: numRows };
  }
}
