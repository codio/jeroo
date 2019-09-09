import { AfterViewInit, Component, ElementRef, ViewChild, Input } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { CodeService, EditorCode } from 'src/app/code.service';
import { CodemirrorService } from 'src/app/codemirror/codemirror.service';
import { PrintService } from 'src/app/print.service';
import { PrintCodeDialogComponent, PrintCodeDialogResult } from './print-code-dialog/print-code-dialog.component';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-print-code',
  templateUrl: './print-code.component.html',
  styleUrls: ['./print-code.component.scss']
})
export class PrintCodeComponent implements AfterViewInit {
  @ViewChild('mainMethodTextArea', { static: false }) mainMethodTextAreaRef: ElementRef;
  @ViewChild('extensionMethodTextArea', { static: false }) extensionMethodTextAreaRef: ElementRef;
  displayMainMethod = false;
  displayExtensionMethods = false;
  editorCode: EditorCode = null;

  constructor(private printService: PrintService,
    private codeMirrorService: CodemirrorService,
    public codeService: CodeService,
    public dialog: MatDialog,
    private route: ActivatedRoute) { }

  // access it in here
  ngAfterViewInit() {
    setTimeout(() => {
      const dialogRef = this.dialog.open(PrintCodeDialogComponent);
      dialogRef.afterClosed().subscribe((result: PrintCodeDialogResult) => {
        if (result !== null && result !== undefined) {
          this.route.queryParams.subscribe(params => {
            this.editorCode = {
              extensionsMethodCode: params.extensionsMethodCode,
              mainMethodCode: params.mainMethodCode
            };
            if (result === PrintCodeDialogResult.PrintMainMethod) {
              this.displayMainMethod = true;
            } else if (result === PrintCodeDialogResult.PrintExtensionMethods) {
              this.displayExtensionMethods = true;
            } else if (result === PrintCodeDialogResult.PrintAll) {
              this.displayMainMethod = true;
              this.displayExtensionMethods = true;
            }

            setTimeout(() => this.printEditors());
          });
        } else {
          this.printService.navigateWithoutPrinting();
        }
      });
    });
  }

  private printEditors() {
    const codemirror = this.codeMirrorService.getCodemirror();
    const editorOptions: CodeMirror.EditorConfiguration = {
      mode: this.codeService.selectedLanguage,
      theme: 'default',
      viewportMargin: Infinity
    };

    if (this.displayMainMethod && this.editorCode) {
      const mainMethodEditor = codemirror.fromTextArea(this.mainMethodTextAreaRef.nativeElement, editorOptions);
      mainMethodEditor.setSize(null, 'auto');
      mainMethodEditor.getWrapperElement().style.paddingBottom = '10px';
      mainMethodEditor.setValue(this.editorCode.mainMethodCode);
    }

    if (this.displayExtensionMethods && this.editorCode) {
      const extensionMethodEditor = codemirror.fromTextArea(this.extensionMethodTextAreaRef.nativeElement, editorOptions);
      extensionMethodEditor.setSize(null, 'auto');
      extensionMethodEditor.getWrapperElement().style.paddingBottom = '10px';
      extensionMethodEditor.setValue(this.editorCode.extensionsMethodCode);
    }

    setTimeout(() => this.printService.onDataReady());
  }
}
