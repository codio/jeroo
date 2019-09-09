import { TestBed } from '@angular/core/testing';
import { CodeService, SelectedLanguage, EditorCode } from './code.service';

describe('CodeService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('assert genCodeStr generates code correctly', () => {
    const service: CodeService = TestBed.get(CodeService);
    const editorCode: EditorCode = {
      extensionsMethodCode: '123\n456',
      mainMethodCode: 'abcde\nfg'
    };
    service.selectedLanguage = SelectedLanguage.Vb;

    const actual = service.genCodeStr(editorCode);
    const expected = `@VB
123
456
@@
abcde
fg`;
    expect(actual).toBe(expected);
  });

  it('assert parseCodeFromStr loads code correctly', () => {
    const service: CodeService = TestBed.get(CodeService);
    const code = `@PYTHON
a = b
1 = 2
# comment
@
@@
def main()
`;
    const actualEditorCode = service.parseCodeFromStr(code);
    const expectedExtensionMethodCode = `a = b
1 = 2
# comment
@`;
    const expectedMainMethodCode = `def main()`;
    const expectedEditorCode: EditorCode = {
      extensionsMethodCode: expectedExtensionMethodCode,
      mainMethodCode: expectedMainMethodCode
    };
    expect(actualEditorCode).toEqual(expectedEditorCode);
  });
});
