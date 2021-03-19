import {Component, Inject, OnInit} from '@angular/core';
import {MAT_DIALOG_DATA, MatDialogRef} from '@angular/material/dialog';
import { FormBuilder, FormGroup } from '@angular/forms';

import { JerooService } from 'src/app/jeroo.service';
import {EditorTabsComponent} from '../../editor-tabs/editor-tabs.component';

export interface DialogData {
  jerooEditor: EditorTabsComponent;
}

@Component({
  selector: 'app-island-open-dialog',
  templateUrl: './island-open-dialog.component.html',
  styleUrls: ['./island-open-dialog.component.scss']
})

export class IslandOpenDialogComponent implements OnInit {
  files: string[] = [];
  form: FormGroup | null = null;
  jerooEditor: EditorTabsComponent;

  constructor(
    private fb: FormBuilder,
    private jerooService: JerooService,
    public dialogRef: MatDialogRef<IslandOpenDialogComponent>,
    @Inject(MAT_DIALOG_DATA) data: DialogData
  ) {
    this.jerooEditor = data.jerooEditor;
  }

  ngOnInit() {
    this.getIslands();
    this.form = this.fb.group({
      name: []
    });
  }

  getIslands(): void {
    this.jerooService.list('.jev')
      .subscribe(files => this.files = files);
  }

  openFile(fileName: string) {
    this.jerooService.load(fileName)
      .subscribe(content => {
        this.jerooEditor?.loadCode(content);
        this.close();
      });
  }
  close() {
    this.dialogRef.close();
  }
}
