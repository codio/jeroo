import { Component } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';

@Component({
  selector: 'app-cache-dialog',
  templateUrl: './cache-dialog.component.html'
})
export class CacheDialogComponent {

  constructor(public dialogRef: MatDialogRef<CacheDialogComponent>) { }
}
