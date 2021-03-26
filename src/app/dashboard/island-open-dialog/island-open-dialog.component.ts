import {Component, Inject, OnInit} from '@angular/core';
import {MAT_DIALOG_DATA, MatDialogRef} from '@angular/material/dialog';
import { FormBuilder, FormGroup } from '@angular/forms';

import { JerooService } from 'src/app/jeroo.service';
import { IslandService } from '../../island.service';
import { JerooIslandComponent } from '../../island/island.component';

export interface DialogData {
  jerooIsland: JerooIslandComponent;
}

@Component({
  selector: 'app-island-open-dialog',
  templateUrl: './island-open-dialog.component.html',
  styleUrls: ['./island-open-dialog.component.scss']
})

export class IslandOpenDialogComponent implements OnInit {
  files: string[] = [];
  form: FormGroup | null = null;
  jerooIsland: JerooIslandComponent;

  constructor(
    private fb: FormBuilder,
    private islandService: IslandService,
    private jerooService: JerooService,
    public dialogRef: MatDialogRef<IslandOpenDialogComponent>,
    @Inject(MAT_DIALOG_DATA) data: DialogData
  ) {
    this.jerooIsland = data.jerooIsland;
  }

  ngOnInit() {
    this.getIslands();
    this.form = this.fb.group({
      name: []
    });
  }

  getIslands(): void {
    this.jerooService.list('.jev')
      .subscribe(files => this.files = files);
  }

  openFile(fileName: string) {
    this.jerooService.load(fileName)
      .subscribe(content => {
        if (content) {
          this.islandService.genIslandFromString(content);
          this.jerooIsland?.redraw();
          this.jerooIsland?.saveInLocal(content);
        }
        this.close();
      });
  }
  close() {
    this.dialogRef.close();
  }
}
