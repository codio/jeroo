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

import { Component, ViewChild, ElementRef, OnInit } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { FormGroup, FormBuilder } from '@angular/forms';
import { IslandService } from 'src/app/island.service';
import { FileSaveService } from '../file-save.service';

@Component({
  selector: 'app-island-save-dialog',
  templateUrl: './island-save-dialog.component.html'
})
export class IslandSaveDialogComponent implements OnInit {
  @ViewChild('fileSaver', { static: true }) fileSaver: ElementRef | null = null;
  form: FormGroup | null = null;

  constructor(
    private fb: FormBuilder,
    private islandService: IslandService,
    private fileSaveService: FileSaveService,
    public dialogRef: MatDialogRef<IslandSaveDialogComponent>
  ) { }

  ngOnInit() {
    this.form = this.fb.group({
      name: []
    });
  }

  save() {
    if (this.form) {
      const islandString = this.islandService.toString();
      const blob = new Blob([islandString], {
        type: 'text/plain'
      });
      this.saveBlob(blob, `${this.form.value.name}.jev`);
      this.dialogRef.close();
    }
  }

  private saveBlob(blob: Blob, fileName: string) {
    if (this.fileSaver) {
      const fileSaver = this.fileSaver.nativeElement as HTMLAnchorElement;
      this.fileSaveService.saveBlob(fileSaver, blob, fileName);
    }
  }

  close() {
    this.dialogRef.close();
  }
}
