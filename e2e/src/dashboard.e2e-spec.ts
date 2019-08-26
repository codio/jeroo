import { DashboardPage } from './dashboard.po';
import { browser } from 'protractor';

describe('Jeroo Tests', () => {
  let page: DashboardPage;

  beforeEach(() => {
    browser.manage().deleteAllCookies();
    const width = 1920;
    const height = 1080;
    browser.driver.manage().window().setSize(width, height);
    page = new DashboardPage();
    page.navigateTo();
    browser.waitForAngularEnabled(false);
  });

  afterEach(() => {
    browser.executeScript('window.sessionStorage.clear();');
    browser.executeScript('window.localStorage.clear();');
  });

  it('Should run program one in java', () => {
    page.setMatrixSize(14, 14);

    page.getExtensionEditorTab().click();
    browser.sleep(500);
    const extensionCode =
      'method pleaseSpin() {\\n' +
      'hop(4);\\n' +
      'turn(RIGHT);\\n' +
      'hop(4);\\n' +
      'turn(RIGHT);\\n' +
      'hop(4);\\n' +
      'turn(RIGHT);\\n' +
      'hop(4);\\n' +
      '}';
    page.writeToCodeMirror(extensionCode);
    page.getMainEditorTab().click();
    browser.sleep(500);
    const mainCode =
      'method main() {\\n' +
      'Jeroo j = new Jeroo(6);\\n' +
      '//Jeroo k = new Jeroo(13, 13, WEST);\\n' +
      'Jeroo m = new Jeroo(13, 12);\\n' +
      'Jeroo n = new Jeroo(13, 11, 43);\\n' +
      'j.pleaseSpin();\\n' +
      'if (!j.isClear(AHEAD) && j.isWater(AHEAD)) {\\n' +
      'j.hop();\\n' +
      '}\\n' +
      '}\\n';
    page.writeToCodeMirror(mainCode);

    page.getSpeedMenu().click();
    page.getSpeed6().click();

    page.getRunContinousButton().click();
    browser.sleep(1250);

    expect(page.getFinalMessage().getText()).toBe('Main:Line 8:LOGIC ERROR: Jeroo is on water');
    expect(page.getJerooName('0').getText()).toBe('j');
    expect(page.getJerooFlowers('0').getText()).toBe('6');
    expect(page.getJerooName('1').getText()).toBe('m');
    expect(page.getJerooFlowers('1').getText()).toBe('0');
    expect(page.getJerooName('2').getText()).toBe('n');
    expect(page.getJerooFlowers('2').getText()).toBe('43');
  });

  it('Should run program two in java', () => {
    page.setMatrixSize(14, 14);

    const code =
      'method main() {\\n' +
      'Jeroo l = new Jeroo();\\n' +
      'Jeroo j = new Jeroo(1, 0, 8);\\n' +
      '// Jeroo k = new Jeroo(13, 13, SOUTH, 8);\\n' +
      'if (j.isFacing(SOUTH) || j.isFacing(WEST)) {\\n' +
      'j.hop();\\n' +
      '} else if (j.isFacing(NORTH)) {\\n' +
      'j.hop();\\n' +
      '} else {\\n' +
      'j.turn(LEFT);\\n' +
      'j.turn(LEFT);\\n' +
      'j.turn(LEFT);\\n' +
      '}\\n' +
      'if(j.isFlower(AHEAD)) {\\n' +
      'j.hop();\\n' +
      'j.pick();\\n' +
      '}\\n' +
      'j.hop();\\n' +
      'if(j.isFlower(HERE)) {\\n' +
      'j.pick();\\n' +
      '}\\n' +
      'j.turn(LEFT);\\n' +
      'if(j.isFacing(EAST)) {\\n' +
      'j.plant();\\n' +
      'j.hop();\\n' +
      '}\\n' +
      'j.toss();\\n' +
      '}';
    page.writeToCodeMirror(code);

    page.getSpeedMenu().click();
    page.getSpeed6().click();

    page.getRunContinousButton().click();
    browser.sleep(1250);

    expect(page.getFinalMessage().getText()).toBe('Program completed');
    expect(page.getJerooName('0').getText()).toBe('l');
    expect(page.getJerooFlowers('0').getText()).toBe('0');
    expect(page.getJerooName('1').getText()).toBe('j');
    expect(page.getJerooFlowers('1').getText()).toBe('6');
  });

  it('Should run program three in java', () => {
    page.setMatrixSize(14, 14);

    const code =
      'method main() {\\n' +
      'Jeroo j = new Jeroo(5);\\n' +
      'Jeroo k = new Jeroo(1, 0);\\n' +
      '// Jeroo k = new Jeroo(1, 0);\\n' +
      'if (j.isJeroo(RIGHT)) {\\n' +
      'j.give(RIGHT);\\n' +
      '}\\n' +
      'if (j.isClear(AHEAD)) {\\n' +
      'j.turn(RIGHT);\\n' +
      'j.give();\\n' +
      '}\\n' +
      '}';
    page.writeToCodeMirror(code);

    page.getSpeedMenu().click();
    page.getSpeed6().click();

    page.getRunContinousButton().click();
    browser.sleep(1250);

    expect(page.getFinalMessage().getText()).toBe('Program completed');
    expect(page.getJerooName('0').getText()).toBe('j');
    expect(page.getJerooFlowers('0').getText()).toBe('3');
    expect(page.getJerooName('1').getText()).toBe('k');
    expect(page.getJerooFlowers('1').getText()).toBe('2');
  });

  it('Should run program one in VB', () => {
    page.setMatrixSize(14, 14);

    page.getLanguageSelection().click();
    browser.sleep(500);
    page.getVbLanguage().click();

    page.getExtensionEditorTab().click();
    browser.sleep(500);
    const extensionCode =
      'Sub pleaseSpin()\\n' +
      'hop(4)\\n' +
      'turn(RIGHT)\\n' +
      'hop(4)\\n' +
      'turn(RIGHT)\\n' +
      'hop(4)\\n' +
      'turn(RIGHT)\\n' +
      'hop(4)\\n' +
      'End sub';
    page.writeToCodeMirror(extensionCode);
    page.getMainEditorTab().click();
    browser.sleep(500);
    const mainCode =
      'Sub main()\\n' +
      'Dim j as Jeroo = new Jeroo(6)\\n' +
      'Dim m as Jeroo = new Jeroo(13, 12)\\n' +
      'Dim n as Jeroo = new Jeroo(13, 11, 43)\\n' +
      'j.pleaseSpin()\\n' +
      'If (NOT j.isClear(AHEAD) AND j.isWater(AHEAD)) Then\\n' +
      'j.hop()\\n' +
      'End If\\n' +
      'End sub';

    page.writeToCodeMirror(mainCode);

    page.getSpeedMenu().click();
    page.getSpeed6().click();

    page.getRunContinousButton().click();
    browser.sleep(1250);

    expect(page.getFinalMessage().getText()).toBe('Main:Line 7:LOGIC ERROR: Jeroo is on water');
    expect(page.getJerooName('0').getText()).toBe('j');
    expect(page.getJerooFlowers('0').getText()).toBe('6');
    expect(page.getJerooName('1').getText()).toBe('m');
    expect(page.getJerooFlowers('1').getText()).toBe('0');
    expect(page.getJerooName('2').getText()).toBe('n');
    expect(page.getJerooFlowers('2').getText()).toBe('43');
  });

  it('Should run program two in VB', () => {
    page.setMatrixSize(14, 14);

    page.getLanguageSelection().click();
    browser.sleep(500);
    page.getVbLanguage().click();

    const code =
      'Sub main()\\n' +
      'Dim l as Jeroo = new Jeroo()\\n' +
      'Dim j as Jeroo = new Jeroo(1, 0, 8)\\n' +
      'If (j.isFacing(SOUTH) OR j.isFacing(WEST)) Then\\n' +
      'j.hop()\\n' +
      'ElseIf (j.isFacing(NORTH)) Then\\n' +
      'j.hop()\\n' +
      'Else\\n' +
      'j.turn(LEFT)\\n' +
      'j.turn(LEFT)\\n' +
      'j.turn(LEFT)\\n' +
      'End If\\n' +
      'If (j.isFlower(AHEAD)) Then\\n' +
      'j.hop()\\n' +
      'End If\\n' +
      'j.hop()\\n' +
      'If (j.isFlower(HERE)) Then\\n' +
      'j.pick()\\n' +
      'End If\\n' +
      'j.turn(LEFT)\\n' +
      'If (j.isFacing(EAST)) Then\\n' +
      'j.plant()\\n' +
      'j.hop()\\n' +
      'End If\\n' +
      'j.toss()\\n' +
      'End sub';
    page.writeToCodeMirror(code);

    page.getSpeedMenu().click();
    page.getSpeed6().click();

    page.getRunContinousButton().click();
    browser.sleep(1250);

    expect(page.getFinalMessage().getText()).toBe('Program completed');
    expect(page.getJerooName('0').getText()).toBe('l');
    expect(page.getJerooFlowers('0').getText()).toBe('0');
    expect(page.getJerooName('1').getText()).toBe('j');
    expect(page.getJerooFlowers('1').getText()).toBe('6');
  });

  it('Should run program three in VB', () => {
    page.setMatrixSize(14, 14);

    page.getLanguageSelection().click();
    browser.sleep(500);
    page.getVbLanguage().click();

    const code =
      'Sub main()\\n' +
      'Dim j as Jeroo = new Jeroo(5)\\n' +
      'Dim k as Jeroo = new Jeroo(1, 0)\\n' +
      'If (j.isJeroo(RIGHT)) Then\\n' +
      'j.give(RIGHT)\\n' +
      'End If\\n' +
      'If (j.isClear(AHEAD)) Then\\n' +
      'j.turn(RIGHT)\\n' +
      'j.give()\\n' +
      'End If\\n' +
      'End Sub';
    page.writeToCodeMirror(code);

    page.getSpeedMenu().click();
    page.getSpeed6().click();

    page.getRunContinousButton().click();
    browser.sleep(1250);

    expect(page.getFinalMessage().getText()).toBe('Program completed');
    expect(page.getJerooName('0').getText()).toBe('j');
    expect(page.getJerooFlowers('0').getText()).toBe('3');
    expect(page.getJerooName('1').getText()).toBe('k');
    expect(page.getJerooFlowers('1').getText()).toBe('2');
  });

  it('Should run program one in python', () => {
    page.setMatrixSize(14, 14);

    page.getLanguageSelection().click();
    browser.sleep(500);
    page.getPythonLanguage().click();

    page.getExtensionEditorTab().click();
    browser.sleep(500);

    const extensionCode =
      'def pleaseSpin(self):\\n' +
      ' self.hop(4)\\n' +
      ' self.turn(RIGHT)\\n' +
      ' self.hop(4)\\n' +
      ' self.turn(RIGHT)\\n' +
      ' self.hop(4)\\n' +
      ' self.turn(RIGHT)\\n' +
      ' self.hop(4)';
    page.writeToCodeMirror(extensionCode);
    page.getMainEditorTab().click();
    browser.sleep(500);

    const mainCode =
      '# Heres my comment\\n' +
      'j = Jeroo(6)\\n' +
      '# k = Jeroo(13, 13, WEST)\\n' +
      'm = Jeroo(13, 12)\\n' +
      'n = Jeroo(13, 11, 43)\\n' +
      'j.pleaseSpin()\\n' +
      'if (not j.isClear(AHEAD) and j.isWater(AHEAD)):\\n' +
      ' j.hop()';
    page.writeToCodeMirror(mainCode);

    page.getSpeedMenu().click();
    page.getSpeed6().click();

    page.getRunContinousButton().click();
    browser.sleep(1250);

    expect(page.getFinalMessage().getText()).toBe('Main:Line 8:LOGIC ERROR: Jeroo is on water');
    expect(page.getJerooName('0').getText()).toBe('j');
    expect(page.getJerooFlowers('0').getText()).toBe('6');
    expect(page.getJerooName('1').getText()).toBe('m');
    expect(page.getJerooFlowers('1').getText()).toBe('0');
    expect(page.getJerooName('2').getText()).toBe('n');
    expect(page.getJerooFlowers('2').getText()).toBe('43');
  });

  it('Should run program two in python', () => {
    page.setMatrixSize(14, 14);

    page.getLanguageSelection().click();
    browser.sleep(500);
    page.getPythonLanguage().click();

    const code =
      'l = Jeroo()\\n' +
      'j = Jeroo(1, 1, 8)\\n' +
      '# k = Jeroo(13, 13, SOUTH, 8)\\n' +
      'if (j.isFacing(SOUTH) or (j.isFacing(WEST))):\\n' +
      ' j.hop()\\n' +
      'elif (j.isFacing(NORTH)):\\n' +
      ' j.hop()\\n' +
      'else:\\n' +
      ' j.turn(LEFT)\\n' +
      ' j.turn(LEFT)\\n' +
      ' j.turn(LEFT)\\n' +
      'if (j.isFlower(AHEAD)):\\n' +
      ' j.hop()\\n' +
      ' # j.pick()\\n' +
      ' j.hop()\\n' +
      'if (j.isFlower(HERE)):\\n' +
      ' j.pick()\\n' +
      'j.turn(LEFT)\\n' +
      'if (j.isFacing(EAST)):\\n' +
      ' j.plant()\\n' +
      ' j.hop()\\n' +
      'j.toss()';
    page.writeToCodeMirror(code);

    page.getSpeedMenu().click();
    page.getSpeed6().click();

    page.getRunContinousButton().click();
    browser.sleep(1250);

    expect(page.getFinalMessage().getText()).toBe('Program completed');
    expect(page.getJerooName('0').getText()).toBe('l');
    expect(page.getJerooFlowers('0').getText()).toBe('0');
    expect(page.getJerooName('1').getText()).toBe('j');
    expect(page.getJerooFlowers('1').getText()).toBe('6');
  });

  it('Should run program three in python', () => {
    page.setMatrixSize(14, 14);

    page.getLanguageSelection().click();
    browser.sleep(500);
    page.getPythonLanguage().click();

    const code =
      'j = Jeroo(1, 1, 5)\\n' +
      'k = Jeroo(2, 1)\\n' +
      'if (j.isJeroo(RIGHT)):\\n' +
      ' j.give(RIGHT)\\n' +
      'if (j.isClear(AHEAD)):\\n' +
      ' j.turn(RIGHT)\\n' +
      ' j.give()';
    page.writeToCodeMirror(code);

    page.getSpeedMenu().click();
    page.getSpeed6().click();

    page.getRunContinousButton().click();
    browser.sleep(1250);

    expect(page.getFinalMessage().getText()).toBe('Program completed');
    expect(page.getJerooName('0').getText()).toBe('j');
    expect(page.getJerooFlowers('0').getText()).toBe('3');
    expect(page.getJerooName('1').getText()).toBe('k');
    expect(page.getJerooFlowers('1').getText()).toBe('2');
  });

  it('Should notice a missing semicolon in Java', () => {
    const code =
      'method main() {\\n' +
      'Jeroo j = new Jeroo(1)\\n' +
      'j.hop()\\n';
    page.writeToCodeMirror(code);
    page.getRunButton().click();

    browser.sleep(500);
    expect(page.getFinalMessage().getText()).toBe('Main:Line 3:Column 1:error:expected one of `;`, `.`, or an operator, found `j`');
  });

  it('Should reload previous work', async () => {
    page.setMatrixSize(20, 30);
    const expectedCode =
      'this is a test';
    page.writeToCodeMirror(expectedCode);
    browser.refresh();

    browser.sleep(500);
    page.getImportProjectDialogBtn().click();
    browser.sleep(500);
    const expectedMatrixSize = { cols: 20, rows: 30 };
    const actualMatrixSize = page.getMatrixSize();
    const actualCode = await page.getCodeMirrorTest();
    expect(expectedCode).toBe(actualCode);
    expect(expectedMatrixSize).toEqual(actualMatrixSize);
  });

  it('Should not reload previous work', async () => {
    page.setMatrixSize(20, 30);
    const expectedCode =
      'this is a test';
    page.writeToCodeMirror(expectedCode);
    browser.refresh();

    browser.sleep(500);
    page.getDontImportProjectDialogBtn().click();
    browser.sleep(500);
    const expectedMatrixSize = { cols: 24, rows: 24 };
    const actualMatrixSize = page.getMatrixSize();
    const actualCode = await page.getCodeMirrorTest();
    expect(actualCode).toBe('');
    expect(expectedMatrixSize).toEqual(actualMatrixSize);
  });

  it('Should change matrix size', async () => {
    page.setMatrixSize(30, 20);
    browser.sleep(500);
    const expectedMatrixSize = { cols: 30, rows: 20 };
    const actualMatrixSize = page.getMatrixSize();
    expect(expectedMatrixSize).toEqual(actualMatrixSize);
  });
});
