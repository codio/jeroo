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

import { Component, ViewChild, ElementRef, OnInit, Inject} from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { FormGroup, FormBuilder } from '@angular/forms';
import { IslandService } from 'src/app/island.service';

import {catchError, map} from 'rxjs/operators';
import {HttpErrorResponse, HttpEventType} from '@angular/common/http';
import {of} from 'rxjs';
import {JerooService} from '../../jeroo.service';

export interface DialogData {
  fileName: string;
}

@Component({
  selector: 'app-island-save-to-server-dialog',
  templateUrl: './island-save-to-server-dialog.component.html'
})
export class IslandSaveToServerDialogComponent implements OnInit {
  @ViewChild('fileSaver', { static: true }) fileSaver: ElementRef | null = null;
  form: FormGroup | null = null;
  fileName: string;

  constructor(
    private fb: FormBuilder,
    private islandService: IslandService,
    private jerooService: JerooService,
    public dialogRef: MatDialogRef<IslandSaveToServerDialogComponent>,
    @Inject(MAT_DIALOG_DATA) data: DialogData
  ) {
    this.fileName = data.fileName;
  }

  ngOnInit() {
    this.form = this.fb.group({
      name: [this.fileName]
    });
  }

  saveToServer() {
    if (this.form) {
      const islandString = this.islandService.toString();
      const blob = new Blob([islandString], {
        type: 'text/plain'
      });
      this.uploadFile(blob, `${this.form?.value.name}.jev`);
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
