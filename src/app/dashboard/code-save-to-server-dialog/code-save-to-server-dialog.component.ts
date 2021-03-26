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

import { JerooService } from 'src/app/jeroo.service';
import { HttpErrorResponse, HttpEventType } from '@angular/common/http';
import { of } from 'rxjs';
import { catchError, map } from 'rxjs/operators';

export interface DialogData {
  editorCode: EditorCode;
  fileName: string;
}

@Component({
  selector: 'app-code-save-to-server-dialog',
  templateUrl: './code-save-to-server-dialog.component.html'
})
export class CodeSaveToServerDialogComponent implements OnInit {
  @ViewChild('fileSaver', { static: true }) fileSaver: ElementRef | null = null;
  @ViewChild('fileUpload', { static: false }) fileUpload: ElementRef | null = null;
  files: object[]  = [];
  form: FormGroup | null = null;
  editorCode: EditorCode;
  fileName: string;

  constructor(
    private fb: FormBuilder,
    private codeService: CodeService,
    private jerooService: JerooService,
    public dialogRef: MatDialogRef<CodeSaveToServerDialogComponent>,
    @Inject(MAT_DIALOG_DATA) data: DialogData
  ) {
    this.editorCode = data.editorCode;
    this.fileName = data.fileName;
  }

  ngOnInit() {
    this.form = this.fb.group({
      name: [this.fileName]
    });
  }

  saveToServer() {
    if (this.form) {
      const jerooCodeString = this.codeService.genCodeStr(this.editorCode);
      const blob = new Blob([jerooCodeString], {
        type: 'text/plain'
      });
      this.uploadFile(blob, `${this.form.value.name}.jsc`);
    }
    this.dialogRef.close();
  }

  uploadFile(file: any, fileName?: any) {
    const formData = new FormData();
    formData.append('file', file, fileName);
    console.log('file', file);
    file.inProgress = true;
    this.jerooService.upload(formData).pipe(
      map(event => {
        switch (event.type) {
          case HttpEventType.UploadProgress:
            file.progress = Math.round(event.loaded * 100 / (event.total || 100));
            break;
          case HttpEventType.Response:
            return event;
        }
      }),
      catchError((_: HttpErrorResponse) => {
        file.inProgress = false;
        return of(`${fileName} upload failed.`);
      })
    ).subscribe((event: any) => {
      if (typeof (event) === 'object') {
        console.log(event.body);
      }
    });
  }

  close() {
    this.dialogRef.close();
  }
}
