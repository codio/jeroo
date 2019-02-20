import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core';
import {
    faFile,
    faFolder,
    faSave,
    faFolderOpen,
    faCopy,
    faPaste,
    faCut,
    faUndo,
    faRedo,
    faStepBackward,
    faStepForward,
    faPlay,
    faPause,
    faStop
} from '@fortawesome/free-solid-svg-icons';
import { DashboardComponent } from './dashboard.component';
import { MaterialModule } from '../material.module';
import { JerooMatrixComponent } from '../jeroo-matrix/jeroo-matrix.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { FormsModule } from '@angular/forms';

library.add(
    faFile,
    faFolder,
    faSave,
    faFolderOpen,
    faCopy,
    faPaste,
    faCut,
    faUndo,
    faRedo,
    faStepBackward,
    faStepForward,
    faPlay,
    faPause,
    faStop
);

describe('DashboardComponent', () => {
    let component: DashboardComponent;
    let fixture: ComponentFixture<DashboardComponent>;

    beforeEach(async(() => {
        TestBed.configureTestingModule({
            imports: [
                MaterialModule,
                FormsModule,
                BrowserAnimationsModule,
                FontAwesomeModule
            ],
            declarations: [
                DashboardComponent,
                JerooMatrixComponent,
            ]
        })
            .compileComponents();
    }));

    beforeEach(() => {
        fixture = TestBed.createComponent(DashboardComponent);
        component = fixture.componentInstance;
        fixture.detectChanges();
    });

    it('should create', () => {
        expect(component).toBeTruthy();
    });
});
