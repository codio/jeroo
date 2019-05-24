import { AfterViewInit, Component, ElementRef, OnInit, ViewChild, Inject } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatDialogRef } from '@angular/material';
import { CodeService, Themes, EditorPreferences } from 'src/app/code.service';
import { CodemirrorService } from 'src/app/codemirror/codemirror.service';
import { LOCAL_STORAGE, WebStorageService } from 'angular-webstorage-service';
import { Storage } from 'src/app/storage';

@Component({
  selector: 'app-editor-preferences',
  templateUrl: './editor-preferences.component.html'
})
export class EditorPreferencesComponent implements OnInit, AfterViewInit {
  @ViewChild('editor') editorRef: ElementRef;
  editor: CodeMirror.Editor;
  colorThemes = [
    Themes.Default,
    Themes.Darcula,
    Themes.Neat,
    Themes.Solarized,
    Themes.TheMattix
  ];
  form: FormGroup;

  constructor(
    public dialogRef: MatDialogRef<EditorPreferencesComponent>,
    private fb: FormBuilder,
    private codeMirrorService: CodemirrorService,
    private codeService: CodeService,
    @Inject(LOCAL_STORAGE) private storage: WebStorageService
  ) { }

  ngOnInit() {
    this.form = this.fb.group({
      fontSize: [
        this.codeService.prefrences.fontSize,
        [
          Validators.min(1),
          Validators.max(30),
          Validators.pattern('[0-9]*'),
          Validators.required
        ]
      ],
      colorTheme: [this.codeService.prefrences.colorTheme]
    });

    this.form.valueChanges.subscribe((val: EditorPreferences) => {
      if (this.editor && this.form.valid) {
        this.editor.getWrapperElement().style.fontSize = `${val.fontSize}px`;
        this.editor.setOption('theme', val.colorTheme);
      }
    });
  }

  ngAfterViewInit() {
    const codemirror = this.codeMirrorService.getCodemirror();
    this.editor = codemirror.fromTextArea(this.editorRef.nativeElement, {
      theme: this.codeService.prefrences.colorTheme,
      lineNumbers: true
    });
    this.editor.getWrapperElement().style.fontSize = `${this.codeService.prefrences.fontSize}px`;
    this.editor.setSize(600, 200);
  }

  onCloseClick() {
    this.dialogRef.close();
  }

  onSaveClick() {
    if (this.form.valid) {
      this.codeService.prefrences = this.form.value;
      this.storage.set(Storage.Preferences, this.form.value);
    }
    this.dialogRef.close();
  }
}
