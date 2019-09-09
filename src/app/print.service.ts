import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { EditorCode } from './code.service';

@Injectable({
  providedIn: 'root'
})
export class PrintService {
  constructor(private router: Router) { }

  printCode(editorCode: EditorCode) {
    this.router.navigate(['/',
      {
        outlets: {
          'print': ['print', 'code']
        }
      }], {
        queryParams: {
          extensionsMethodCode: editorCode.extensionsMethodCode,
          mainMethodCode: editorCode.mainMethodCode
        }
      });
  }

  printIsland() {
    this.router.navigate(['/',
      {
        outlets: {
          'print': ['print', 'map']
        }
      }]);
  }

  onDataReady() {
    setTimeout(() => {
      window.print();
      this.router.navigate([{ outlets: { print: null } }]);
    });
  }

  navigateWithoutPrinting() {
    this.router.navigate([{ outlets: { print: null } }]);
  }
}
