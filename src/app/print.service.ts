import { Injectable } from '@angular/core';
import { Router } from '@angular/router';

@Injectable({
  providedIn: 'root'
})
export class PrintService {
  constructor(private router: Router) { }

  printDocument(documentName: string) {
    this.router.navigate(['/',
                          { outlets: {
                            'print': ['print', documentName]
                          } }]);
  }

  onDataReady() {
    setTimeout(() => {
      window.print();
      this.router.navigate([{ outlets: { print: null }}]);
    });
  }

  navigateWithoutPrinting() {
    this.router.navigate([{ outlets: { print: null }}]);
  }
}
