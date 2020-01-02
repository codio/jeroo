/* **********************************************************************
Jeroo is a programming language learning tool for students and teachers.
Copyright (C) <2019>  <Benjamin Konz>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
********************************************************************** */

import { AfterViewInit, Component, ElementRef, OnInit, ViewChild, Inject } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatDialogRef } from '@angular/material/dialog';
import { CodeService, Themes, EditorPreferences } from 'src/app/code.service';
import { CodemirrorService } from 'src/app/codemirror/codemirror.service';
import { LOCAL_STORAGE, WebStorageService } from 'angular-webstorage-service';
import { Storage } from 'src/app/storage';

@Component({
  selector: 'app-editor-preferences',
  templateUrl: './editor-preferences.component.html'
})
export class EditorPreferencesComponent implements OnInit, AfterViewInit {
  @ViewChild('editor', { static: true }) editorTextArea: ElementRef | null = null;
  editor: CodeMirror.Editor | null = null;
  colorThemes = [
    Themes.Default,
    Themes.Darcula,
    Themes.Neat,
    Themes.Solarized,
    Themes.TheMattix
  ];
  form: FormGroup | null = null;

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
      if (this.editor && this.form && this.form.valid) {
        this.editor.getWrapperElement().style.fontSize = `${val.fontSize}px`;
        this.editor.setOption('theme', val.colorTheme);
      }
    });
  }

  ngAfterViewInit() {
    if (this.editorTextArea) {
      const editorTextArea = this.editorTextArea.nativeElement;
      const codemirror = this.codeMirrorService.getCodemirror();
      this.editor = codemirror.fromTextArea(editorTextArea, {
        theme: this.codeService.prefrences.colorTheme,
        lineNumbers: true
      });
      this.editor.getWrapperElement().style.fontSize = `${this.codeService.prefrences.fontSize}px`;
      this.editor.setSize(600, 200);
    }
  }

  onCloseClick() {
    this.dialogRef.close();
  }

  onSaveClick() {
    if (this.form && this.form.valid) {
      this.codeService.prefrences = this.form.value;
      this.storage.set(Storage.Preferences, this.form.value);
    }
    this.dialogRef.close();
  }
}
