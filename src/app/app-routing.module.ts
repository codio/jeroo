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

import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { DashboardComponent } from './dashboard/dashboard.component';
import { LevelEditorComponent } from './leveleditor/dashboard.component';
import { PrintLayoutComponent } from './print-layout/print-layout.component';
import { PrintIslandComponent } from './print-layout/print-island/print-island.component';
import { PrintCodeComponent } from './print-layout/print-code/print-code.component';


const routes: Routes = [
    { path: 'help', loadChildren: () => import('./help/help.module').then(m => m.HelpModule) },
    { path: 'dashboard', component: DashboardComponent },
    { path: 'editor', component: LevelEditorComponent },
    { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
    {
        path: 'print',
        outlet: 'print',
        component: PrintLayoutComponent,
        children: [
            {
                path: 'island', component: PrintIslandComponent
            },
            {
                path: 'code', component: PrintCodeComponent
            }
        ]
    }
];

@NgModule({
    imports: [RouterModule.forRoot(routes)],
    exports: [RouterModule]
})
export class AppRoutingModule { }
