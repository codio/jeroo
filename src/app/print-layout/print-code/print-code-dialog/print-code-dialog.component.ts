import { Component } from '@angular/core';
import { MatDialogRef } from '@angular/material';

export enum PrintCodeDialogResult {
  PrintMainMethod,
  PrintExtensionMethods,
  PrintAll
}

interface Option {
  viewValue: string;
  value: PrintCodeDialogResult;
}

@Component({
  selector: 'app-print-code-dialog',
  templateUrl: './print-code-dialog.component.html',
  styleUrls: ['./print-code-dialog.component.scss']
})
export class PrintCodeDialogComponent {
  options: Option[] = [
    { viewValue: 'ALL source code', value: PrintCodeDialogResult.PrintAll },
    { viewValue: 'MAIN method only', value: PrintCodeDialogResult.PrintMainMethod },
    { viewValue: 'JEROO METHODS only', value: PrintCodeDialogResult.PrintExtensionMethods }
  ];
  selectedOption = this.options[0].value;

  constructor(public dialogRef: MatDialogRef<PrintCodeDialogComponent>) { }

  onOkClick() {
    this.dialogRef.close(this.selectedOption);
  }

  onCancelClick() {
    this.dialogRef.close(null);
  }
}
