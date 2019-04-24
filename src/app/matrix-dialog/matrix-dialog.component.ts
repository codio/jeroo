import { Component, OnInit, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef, MatDialog } from '@angular/material';
import { FormGroup, FormBuilder, Validators } from '@angular/forms';
import { WarningDialogComponent } from '../warning-dialog/warning-dialog.component';

export interface DialogData {
    xValue: number;
    yValue: number;
}

@Component({
    selector: 'app-matrix-dialog',
    templateUrl: './matrix-dialog.component.html',
    styleUrls: ['./matrix-dialog.component.scss']
})
export class MatrixDialogComponent implements OnInit {
    form: FormGroup;
    widthValue: number;
    heightValue: number;

    constructor(private fb: FormBuilder,
        public dialogRef: MatDialogRef<MatrixDialogComponent>,
        private dialog: MatDialog,
        @Inject(MAT_DIALOG_DATA) data: DialogData) {
        this.widthValue = data.xValue;
        this.heightValue = data.yValue;
    }

    save() {
        const dialogRef = this.dialog.open(WarningDialogComponent);
        dialogRef.afterClosed().subscribe((cont) => {
            if (cont) {
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
            xValue: [this.widthValue, [Validators.min(1), Validators.max(50), Validators.pattern('[0-9]*'), Validators.required]],
            yValue: [this.heightValue, [Validators.min(1), Validators.max(50), Validators.pattern('[0-9]*'), Validators.required]]
        });
    }
}
