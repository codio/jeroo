import { Component, ViewChild, ElementRef, OnInit } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { FormGroup, FormBuilder } from '@angular/forms';
import { MatrixService } from 'src/app/matrix.service';

@Component({
  selector: 'app-island-save-dialog',
  templateUrl: './island-save-dialog.component.html'
})
export class IslandSaveDialogComponent implements OnInit {
  @ViewChild('fileSaver', { static: true }) fileSaver: ElementRef;
  form: FormGroup;

  constructor(
    private fb: FormBuilder,
    private matrixService: MatrixService,
    public dialogRef: MatDialogRef<IslandSaveDialogComponent>
  ) { }

  ngOnInit() {
    this.form = this.fb.group({
      name: []
    });
  }

  save() {
    const islandString = this.matrixService.toString();
    const blob = new Blob([islandString], {
      type: 'text/plain'
    });
    this.saveBlob(blob, `${this.form.value.name}.jev`);
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
