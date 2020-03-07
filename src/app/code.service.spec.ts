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

import { TestBed } from '@angular/core/testing';
import { CodeService, SelectedLanguage, EditorCode } from './code.service';

describe('CodeService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('assert genCodeStr generates code correctly', () => {
    const service = TestBed.inject(CodeService);
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
    const service = TestBed.inject(CodeService);
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
