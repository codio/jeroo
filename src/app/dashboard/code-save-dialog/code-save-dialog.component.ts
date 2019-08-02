import { Component, ViewChild, ElementRef, OnInit } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { FormGroup, FormBuilder } from '@angular/forms';
import { CodeService } from 'src/app/code.service';

@Component({
  selector: 'app-code-save-dialog',
  templateUrl: './code-save-dialog.component.html'
})
export class CodeSaveDialogComponent implements OnInit {
  @ViewChild('fileSaver', { static: true }) fileSaver: ElementRef;
  form: FormGroup;

  constructor(
    private fb: FormBuilder,
    private codeService: CodeService,
    public dialogRef: MatDialogRef<CodeSaveDialogComponent>
  ) { }

  ngOnInit() {
    this.form = this.fb.group({
      name: []
    });
  }

  save() {
    const jerooCodeString = this.codeService.genCodeStr();
    const blob = new Blob([jerooCodeString], {
      type: 'text/plain'
    });
    this.saveBlob(blob, `${this.form.value.name}.jsc`);
    this.dialogRef.close();
  }

  private saveBlob(blob: Blob, fileName: string) {
    const fileSaver = (this.fileSaver.nativeElement as HTMLAnchorElement);
    const saveBlob = (function () {
      return function () {
        const url = window.URL.createObjectURL(blob);
        fileSaver.href = url;
        fileSaver.download = fileName;
        fileSaver.click();
        window.URL.revokeObjectURL(url);
      };
    }());

    saveBlob();
  }

  close() {
    this.dialogRef.close();
  }
}
