import { Component } from '@angular/core';
import { MatDialogRef } from '@angular/material';

@Component({
    selector: 'app-dashboard-dialog-about',
    templateUrl: './dashboard-dialog-about.component.html',
})
export class DashboardDialogAboutComponent {
    constructor(public dialogRef: MatDialogRef<DashboardDialogAboutComponent>) {}

    onCloseClick(): void {
        this.dialogRef.close();
    }
}
