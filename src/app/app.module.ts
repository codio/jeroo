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
import { JerooIslandComponent } from './island/island.component';
import { ChnageIslandSizeDialogComponent } from './change-island-size-dialog/change-island-size-dialog.component';
import { MaterialModule } from './material.module';
import { FlexLayoutModule } from '@angular/flex-layout';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { DashboardComponent } from './dashboard/dashboard.component';
import { MessagesComponent } from './messages/messages.component';
import { EditorComponent } from './editor/editor.component';
import { StorageServiceModule } from 'angular-webstorage-service';
import { DashboardDialogAwardsComponent } from './dashboard/dashboard-dialog-awards/dashboard-dialog-awards.component';
import { DashboardDialogHistoryComponent } from './dashboard/dashboard-dialog-history/dashboard-dialog-history.component';
import { DashboardDialogCopyrightComponent } from './dashboard/dashboard-dialog-copyright/dashboard-dialog-copyright.component';
import { EditorTabsComponent } from './editor-tabs/editor-tabs.component';
import { CacheDialogComponent } from './cache-dialog/cache-dialog.component';
import { JerooStatusComponent } from './jeroo-status/jeroo-status.component';
import { DashboardDialogAboutComponent } from './dashboard/dashboard-dialog-about/dashboard-dialog-about.component';
import { WarningDialogComponent } from './warning-dialog/warning-dialog.component';
import { PrintLayoutComponent } from './print-layout/print-layout.component';
import { PrintIslandComponent } from './print-layout/print-island/print-island.component';
import { PrintCodeComponent } from './print-layout/print-code/print-code.component';
import { PrintCodeDialogComponent } from './print-layout/print-code/print-code-dialog/print-code-dialog.component';
import { EditorPreferencesComponent } from './dashboard/editor-preferences/editor-preferences.component';
import { CompilationErrorMessageComponent } from './messages/compilation-error-message/compilation-error-message.component';
import { LoggingMessageComponent } from './messages/logging-message/logging-message.component';
import { CodeSaveDialogComponent } from './dashboard/code-save-dialog/code-save-dialog.component';
import { IslandSaveDialogComponent } from './dashboard/island-save-dialog/island-save-dialog.component';
import { RuntimeErrorMessageComponent } from './messages/runtime-error-message/runtime-error-message.component';

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
    JerooIslandComponent,
    ChnageIslandSizeDialogComponent,
    MessagesComponent,
    EditorComponent,
    EditorTabsComponent,
    CacheDialogComponent,
    JerooStatusComponent,
    DashboardDialogAboutComponent,
    DashboardDialogAwardsComponent,
    DashboardDialogHistoryComponent,
    DashboardDialogCopyrightComponent,
    WarningDialogComponent,
    PrintLayoutComponent,
    PrintIslandComponent,
    PrintCodeComponent,
    PrintCodeDialogComponent,
    EditorPreferencesComponent,
    CompilationErrorMessageComponent,
    LoggingMessageComponent,
    CodeSaveDialogComponent,
    IslandSaveDialogComponent,
    RuntimeErrorMessageComponent
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
    HotkeyModule.forRoot(),
  ],
  providers: [],
  bootstrap: [AppComponent],
  entryComponents: [
    ChnageIslandSizeDialogComponent,
    CacheDialogComponent,
    DashboardDialogAboutComponent,
    DashboardDialogAwardsComponent,
    DashboardDialogHistoryComponent,
    DashboardDialogCopyrightComponent,
    WarningDialogComponent,
    PrintCodeDialogComponent,
    EditorPreferencesComponent,
    CodeSaveDialogComponent,
    IslandSaveDialogComponent
  ]
})
export class AppModule { }
