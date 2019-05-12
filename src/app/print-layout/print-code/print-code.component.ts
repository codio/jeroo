import { AfterViewInit, Component, ElementRef, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material';
import { CodeService } from 'src/app/code.service';
import { CodemirrorService } from 'src/app/codemirror/codemirror.service';
import { PrintService } from 'src/app/print.service';
import { PrintCodeDialogComponent, PrintCodeDialogResult } from './print-code-dialog/print-code-dialog.component';

@Component({
    selector: 'app-print-code',
    templateUrl: './print-code.component.html',
    styleUrls: ['./print-code.component.scss']
})
export class PrintCodeComponent implements AfterViewInit {
    @ViewChild('mainMethodTextArea') mainMethodTextAreaRef: ElementRef;
    @ViewChild('extensionMethodTextArea') extensionMethodTextAreaRef: ElementRef;
    displayMainMethod = false;
    displayExtensionMethods = false;

    constructor(private printService: PrintService,
                private codeMirrorService: CodemirrorService,
                public codeService: CodeService,
                public dialog: MatDialog) { }

    ngAfterViewInit() {
        setTimeout(() => {
            const dialogRef = this.dialog.open(PrintCodeDialogComponent);
            dialogRef.afterClosed().subscribe((result: PrintCodeDialogResult) => {
                if (result !== null && result !== undefined) {
                    if (result === PrintCodeDialogResult.PrintMainMethod) {
                        this.displayMainMethod = true;
                    } else if (result === PrintCodeDialogResult.PrintExtensionMethods) {
                        this.displayExtensionMethods = true;
                    } else if (result === PrintCodeDialogResult.PrintAll) {
                        this.displayMainMethod = true;
                        this.displayExtensionMethods = true;
                    }

                    setTimeout(() => this.printEditors());
                } else {
                    this.printService.navigateWithoutPrinting();
                }
            });
        });
    }

    private printEditors() {
        const codemirror = this.codeMirrorService.getCodemirror();
        const editorOptions: CodeMirror.EditorConfiguration = {
            mode: 'jeroo-java',
            theme: 'default',
            viewportMargin: Infinity
        };

        if (this.displayMainMethod) {
            const mainMethodEditor = codemirror.fromTextArea(this.mainMethodTextAreaRef.nativeElement, editorOptions);
            mainMethodEditor.setValue(this.codeService.mainMethodCode);
        }

        if (this.displayExtensionMethods) {
            const extensionMethodEditor = codemirror.fromTextArea(this.extensionMethodTextAreaRef.nativeElement, editorOptions);
            extensionMethodEditor.setValue(this.codeService.extensionMethodCode);
        }

        setTimeout(() => this.printService.onDataReady());
    }
}
