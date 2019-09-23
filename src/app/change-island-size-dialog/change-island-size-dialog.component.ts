import { Component, OnInit, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef, MatDialog } from '@angular/material/dialog';
import { FormGroup, FormBuilder, Validators } from '@angular/forms';
import { WarningDialogComponent } from '../warning-dialog/warning-dialog.component';

export interface DialogData {
  colValue: number;
  rowValue: number;
}

@Component({
  selector: 'app-change-island-dialog-dialog',
  templateUrl: './change-island-size-dialog.component.html',
  styleUrls: ['./change-island-size-dialog.component.scss']
})
export class ChnageIslandSizeDialogComponent implements OnInit {
  form: FormGroup | null = null;
  colValue: number;
  rowValue: number;

  constructor(private fb: FormBuilder,
    public dialogRef: MatDialogRef<ChnageIslandSizeDialogComponent>,
    private dialog: MatDialog,
    @Inject(MAT_DIALOG_DATA) data: DialogData) {
    this.colValue = data.colValue;
    this.rowValue = data.rowValue;
  }

  save() {
    const dialogRef = this.dialog.open(WarningDialogComponent);
    dialogRef.afterClosed().subscribe((cont) => {
      if (cont && this.form) {
        this.dialogRef.close(this.form.value);
      } else {
        this.dialogRef.close();
      }
    });
  }

  close() {
    this.dialogRef.close();
  }

  ngOnInit() {
    this.form = this.fb.group({
      colValue: [this.colValue, [Validators.min(1), Validators.max(50), Validators.pattern('[0-9]*'), Validators.required]],
      rowValue: [this.rowValue, [Validators.min(1), Validators.max(50), Validators.pattern('[0-9]*'), Validators.required]]
    });
  }
}