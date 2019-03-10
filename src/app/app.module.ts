import 'hammerjs';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
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
    faStop,
    faBars,
    faEraser,
    faPrint
} from '@fortawesome/free-solid-svg-icons';
import { NgModule } from '@angular/core';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { JerooMatrixComponent } from './jeroo-matrix/jeroo-matrix.component';
import { MatrixDialogComponent } from './matrix-dialog/matrix-dialog.component';
import { MaterialModule } from './material.module';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { DashboardComponent } from './dashboard/dashboard.component';

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
    faStop,
    faBars,
    faEraser,
    faPrint
);

@NgModule({
    declarations: [
        AppComponent,
        DashboardComponent,
        JerooMatrixComponent,
        MatrixDialogComponent,
    ],
    imports: [
        BrowserModule,
        AppRoutingModule,
        MaterialModule,
        BrowserAnimationsModule,
        FormsModule,
        ReactiveFormsModule,
        FontAwesomeModule
    ],
    providers: [],
    bootstrap: [AppComponent],
    entryComponents: [MatrixDialogComponent]
})
export class AppModule { }
