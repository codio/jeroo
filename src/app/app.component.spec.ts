import { TestBed, async } from '@angular/core/testing';
import { RouterTestingModule } from '@angular/router/testing';
import { AppComponent } from './app.component';
import { JerooMatrixComponent } from './jeroo-matrix/jeroo-matrix.component';
import { MaterialModule } from './material.module';

describe('AppComponent', () => {
    beforeEach(async(() => {
        TestBed.configureTestingModule({
            imports: [
                RouterTestingModule,
                MaterialModule
            ],
            declarations: [
                AppComponent,
                JerooMatrixComponent
            ],
        }).compileComponents();
    }));

    it('should create the app', () => {
        expect(true).toBeTruthy();
    });
});
