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

import { Component, ViewChild, ElementRef, OnInit, Inject } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { FormGroup, FormBuilder } from '@angular/forms';
import { CodeService, EditorCode } from 'src/app/code.service';

export interface DialogData {
  editorCode: EditorCode;
}

@Component({
  selector: 'app-code-save-dialog',
  templateUrl: './code-save-dialog.component.html'
})
export class CodeSaveDialogComponent implements OnInit {
  @ViewChild('fileSaver', { static: true }) fileSaver: ElementRef | null = null;
  form: FormGroup | null = null;
  editorCode: EditorCode;

  constructor(
    private fb: FormBuilder,
    private codeService: CodeService,
    public dialogRef: MatDialogRef<CodeSaveDialogComponent>,
    @Inject(MAT_DIALOG_DATA) data: DialogData
  ) {
    this.editorCode = data.editorCode;
  }

  ngOnInit() {
    this.form = this.fb.group({
      name: []
    });
  }

  save() {
    if (this.form) {
      const jerooCodeString = this.codeService.genCodeStr(this.editorCode);
      const blob = new Blob([jerooCodeString], {
        type: 'text/plain'
      });
      this.saveBlob(blob, `${this.form.value.name}.jsc`);
    }
    this.dialogRef.close();
  }

  private saveBlob(blob: Blob, fileName: string) {
    if (this.fileSaver) {
      const fileSaver = (this.fileSaver.nativeElement as HTMLAnchorElement);
      const saveBlob = (function() {
        return function() {
          const url = window.URL.createObjectURL(blob);
          fileSaver.href = url;
          fileSaver.download = fileName;
          fileSaver.click();
          window.URL.revokeObjectURL(url);
        };
      }());

      saveBlob();
    }
  }

  close() {
    this.dialogRef.close();
  }
}
