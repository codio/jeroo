import { TestBed } from '@angular/core/testing';
import { CodeService, SelectedLanguage } from './code.service';

describe('CodeService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('assert genCodeStr generates code correctly', () => {
    const service: CodeService = TestBed.get(CodeService);
    service.mainMethodCode = 'abcde\nfg';
    service.extensionMethodCode = '123\n456';
    service.selectedLanguage = SelectedLanguage.Vb;

    const actual = service.genCodeStr();
    const expected = `@VB
123
456
@@
abcde
fg`;
    expect(actual).toBe(expected);
  });

  it('assert loadCodeFromStr loads code correctly', () => {
    const service: CodeService = TestBed.get(CodeService);
    const code = `@PYTHON
a = b
1 = 2
# comment
@
@@
def main()
`;
    service.loadCodeFromStr(code);
    const expectedExtensionMethodCode = `a = b
1 = 2
# comment
@`;
    const expectedMainMethodCode = `def main()`;
    expect(service.extensionMethodCode).toBe(expectedExtensionMethodCode);
    expect(service.mainMethodCode).toBe(expectedMainMethodCode);
  });
});
