import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { JerooMatrixComponent } from './jeroo-matrix.component';

import { MaterialModule } from '../material.module';
import { ReactiveFormsModule } from '@angular/forms';
import { Browser } from 'selenium-webdriver';

describe('JerooMatrixComponent', () => {
  let component: JerooMatrixComponent;
  let fixture: ComponentFixture<JerooMatrixComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      imports: [
        MaterialModule,
        ReactiveFormsModule
      ],
      declarations: [ JerooMatrixComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(JerooMatrixComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

describe('JerooMatrix', function() {

});
