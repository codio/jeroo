import { Component } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';

@Component({
  selector: 'app-dashboard-dialog-copyright',
  templateUrl: './dashboard-dialog-copyright.component.html'
})
export class DashboardDialogCopyrightComponent {

  constructor(
    public dialogRef: MatDialogRef<DashboardDialogCopyrightComponent>) {}

  onCloseClick(): void {
    this.dialogRef.close();
  }
}
