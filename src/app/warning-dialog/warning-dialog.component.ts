import { Component } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';

@Component({
  selector: 'app-warning-dialog',
  templateUrl: './warning-dialog.component.html'
})
export class WarningDialogComponent {

  constructor(public dialogRef: MatDialogRef<WarningDialogComponent>) {}

  onCloseClick(): void {
    this.dialogRef.close(false);
  }

  onContinueClick(): void {
    this.dialogRef.close(true);
  }

}
