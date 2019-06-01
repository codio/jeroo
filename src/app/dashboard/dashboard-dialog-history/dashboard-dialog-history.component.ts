import { Component } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';

@Component({
  selector: 'app-dashboard-dialog-history',
  templateUrl: './dashboard-dialog-history.component.html'
})
export class DashboardDialogHistoryComponent {

  constructor(
    public dialogRef: MatDialogRef<DashboardDialogHistoryComponent>) {}

  onCloseClick(): void {
    this.dialogRef.close();
  }
}
