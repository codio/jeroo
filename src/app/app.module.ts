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
import { HotkeyModule } from 'angular2-hotkeys';
import { NgModule } from '@angular/core';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { JerooMatrixComponent } from './jeroo-matrix/jeroo-matrix.component';
import { MatrixDialogComponent } from './matrix-dialog/matrix-dialog.component';
import { MaterialModule } from './material.module';
import { FlexLayoutModule } from '@angular/flex-layout';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { DashboardComponent } from './dashboard/dashboard.component';
import { DisplayErrorMessageComponent } from './display-error-message/display-error-message.component';
import { TextEditorComponent } from './text-editor/text-editor.component';
import { StorageServiceModule } from 'angular-webstorage-service';
import { DashboardDialogAwardsComponent } from './dashboard-dialog-awards/dashboard-dialog-awards.component';
import { DashboardDialogHistoryComponent } from './dashboard-dialog-history/dashboard-dialog-history.component';
import { DashboardDialogCopyrightComponent } from './dashboard-dialog-copyright/dashboard-dialog-copyright.component';
import { EditorTabAreaComponent } from './editor-tab-area/editor-tab-area.component';
import { DashboardDialogAboutComponent } from './dashboard-dialog-about/dashboard-dialog-about.component';

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
        DisplayErrorMessageComponent,
        TextEditorComponent,
        EditorTabAreaComponent,
        DashboardDialogAboutComponent,
        DashboardDialogAwardsComponent,
        DashboardDialogHistoryComponent,
        DashboardDialogCopyrightComponent
    ],
    imports: [
        BrowserModule,
        AppRoutingModule,
        MaterialModule,
        FlexLayoutModule,
        BrowserAnimationsModule,
        FormsModule,
        ReactiveFormsModule,
        FontAwesomeModule,
        StorageServiceModule,
        HotkeyModule.forRoot()
    ],
    providers: [],
    bootstrap: [AppComponent],
    entryComponents: [
        MatrixDialogComponent,
        DashboardDialogAboutComponent,
        DashboardDialogAwardsComponent,
        DashboardDialogHistoryComponent,
        DashboardDialogCopyrightComponent
    ]
})
export class AppModule { }
