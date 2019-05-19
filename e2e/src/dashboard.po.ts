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
        browser.sleep(500);
        this.getChangeMapSize().click();
        this.getXValueInput().clear();
        this.getXValueInput().sendKeys('14');
        this.getYValueInput().clear();
        this.getYValueInput().sendKeys('14');
        this.getSubmitMatrixDialogButton().click();
        this.getYesWarningButton().click();
    }

    getRunButton() {
        return element(by.name('runButton'));
    }

    getRunContinousButton() {
        return element(by.name('runContiniousButton'));
    }

    getPauseButton() {
        return element(by.name('pauseButton'));
    }

    getStopButton() {
        return element(by.name('stopButton'));
    }

    getSpeedSlider() {
        return element(by.name('speedSlider'));
    }

    getIslandEditMenu() {
        return element(by.name('islandEditMenu'));
    }

    getNewMapMenuItem() {
        return element(by.name('newMapMenuItem'));
    }

    getChangeMapSize() {
        return element(by.name('changeMapSize'));
    }

    getCloseMatrixDialogButton() {
        return element(by.name('closeMatrixDialogButton'));
    }

    getSubmitMatrixDialogButton() {
        return element(by.name('submitMatrixDialogButton'));
    }

    getXValueInput() {
        return element(by.name('xValueInput'));
    }

    getYValueInput() {
        return element(by.name('yValueInput'));
    }

    getYesWarningButton() {
        return element(by.name('yesWarningButton'));
    }

    getNoWarningButton() {
        return element(by.name('noWarningButton'));
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
