import { Component } from '@angular/core';
import { MatDialogRef } from '@angular/material';

@Component({
  selector: 'app-dashboard-dialog-awards',
  templateUrl: './dashboard-dialog-awards.component.html'
})
export class DashboardDialogAwardsComponent {
  constructor(public dialogRef: MatDialogRef<DashboardDialogAwardsComponent>) {}

  onCloseClick(): void {
    this.dialogRef.close();
  }
}
