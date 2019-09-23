import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { DashboardComponent } from './dashboard/dashboard.component';
import { PrintLayoutComponent } from './print-layout/print-layout.component';
import { PrintIslandComponent } from './print-layout/print-island/print-island.component';
import { PrintCodeComponent } from './print-layout/print-code/print-code.component';


const routes: Routes = [
    { path: 'help', loadChildren: () => import('./help/help.module').then(m => m.HelpModule) },
    { path: 'dashboard', component: DashboardComponent },
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
