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

  setMatrixSize(cols: number, rows: number) {
    this.getIslandEditMenu().click();
    this.getChangeMapSize().click();
    this.getXValueInput().clear();
    this.getXValueInput().sendKeys(`${cols}`);
    this.getYValueInput().clear();
    this.getYValueInput().sendKeys(`${rows}`);
    this.getSubmitMatrixDialogButton().click();
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

  getNewMapMenuItem() {
    return element(by.id('newMapMenuItem'));
  }

  getChangeMapSize() {
    return element(by.id('changeMapSize'));
  }

  getCloseMatrixDialogButton() {
    return element(by.id('closeMatrixDialogButton'));
  }

  getSubmitMatrixDialogButton() {
    return element(by.id('submitMatrixDialogButton'));
  }

  getXValueInput() {
    return element(by.id('xValueInput'));
  }

  getYValueInput() {
    return element(by.id('yValueInput'));
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

  async getMatrixSize() {
    this.getIslandEditMenu().click();
    this.getChangeMapSize().click();
    const numCols = parseInt(await this.getXValueInput().getAttribute('value'), 10);
    const numRows = parseInt(await this.getYValueInput().getAttribute('value'), 10);
    this.getCloseMatrixDialogButton().click();
    return { cols: numCols, rows: numRows };
  }
}
