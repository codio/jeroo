import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { MatrixDialogComponent } from './matrix-dialog.component';
import { MaterialModule } from '../material.module';
import { ReactiveFormsModule } from '@angular/forms';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatrixService } from '../matrix.service';

describe('MatrixDialogComponent', () => {
  let component: MatrixDialogComponent;
  let fixture: ComponentFixture<MatrixDialogComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      imports: [
        MaterialModule,
        ReactiveFormsModule,
        MatDialogModule,
        BrowserAnimationsModule
      ],
      providers: [
        MatrixService, {provide: MatDialogRef, useValue: {}},
        MatrixService, {provide: MAT_DIALOG_DATA, useValue: {}},
     ],
      declarations: [ MatrixDialogComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(MatrixDialogComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
