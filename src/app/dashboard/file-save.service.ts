import { Injectable } from '@angular/core';

@Injectable({
    providedIn: 'root'
})
export class FileSaveService {
    constructor() { }

    saveBlob(fileSaver: HTMLAnchorElement, blob: Blob, fileName: string) {
        if (window.navigator && window.navigator.msSaveOrOpenBlob) {
            window.navigator.msSaveOrOpenBlob(blob, fileName);
        } else {
            const url = window.URL.createObjectURL(blob);
            fileSaver.href = url;
            fileSaver.download = fileName;
            fileSaver.click();
            window.URL.revokeObjectURL(url);
        }
    }
}
