import { browser, by, element } from 'protractor';

export class DashboardPage {

  navigateTo() {
    return browser.get('/dashboard');
  }

  writeToCodeMirror(incomingText: string) {
    browser.executeScript(
      'var editor = document.getElementsByClassName(\'CodeMirror\')[0].CodeMirror;editor.setValue(\'' + incomingText + '\');'
    );
  }

  changeSizeForLanguageTests() {
    this.getIslandEditMenu().click();
    this.getChangeMapSize().click();
    this.getXValueInput().clear();
    this.getXValueInput().sendKeys('14');
    this.getYValueInput().clear();
    this.getYValueInput().sendKeys('14');
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

  // Status Information Area Elements

  // identifier is 0, 1, 2, 3 based on when it was initialized
  getJerooName(identifier: string) {
    return element(by.id('name' + identifier));
  }

  getJerooFlowers(identifier: string) {
    return element(by.id('flowers' + identifier));
  }

}
