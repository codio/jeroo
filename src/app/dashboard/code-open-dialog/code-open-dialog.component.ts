import {Component, Inject, OnInit} from '@angular/core';
import {MAT_DIALOG_DATA, MatDialogRef} from '@angular/material/dialog';
import { FormBuilder, FormGroup } from '@angular/forms';

import { JerooService } from 'src/app/jeroo.service';
import { EditorTabsComponent } from '../../editor-tabs/editor-tabs.component';

export interface DialogData {
  jerooEditor: EditorTabsComponent;
}

@Component({
  selector: 'app-code-open-dialog',
  templateUrl: './code-open-dialog.component.html',
  styleUrls: ['./code-open-dialog.component.scss']
})
export class CodeOpenDialogComponent implements OnInit {
  files: string[] = [];
  form: FormGroup | null = null;
  jerooEditor: EditorTabsComponent;

  constructor(
    private fb: FormBuilder,
    private jerooService: JerooService,
    public dialogRef: MatDialogRef<CodeOpenDialogComponent>,
    @Inject(MAT_DIALOG_DATA) data: DialogData
  ) {
    this.jerooEditor = data.jerooEditor;
  }

  ngOnInit() {
    this.getFiles();
    this.form = this.fb.group({});
  }

  getFiles(): void {
    this.jerooService.list('.jsc')
      .subscribe(files => this.files = files);
  }

  openFile(fileName: string) {
    this.jerooService.load(fileName)
      .subscribe(content => {
        if (content) {
          this.jerooEditor?.setFileName(fileName.replace('.jsc', ''));
          this.jerooEditor?.loadCode(content);
        }
        this.close();
      });
  }

  close() {
    this.dialogRef.close();
  }
}
