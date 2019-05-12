import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { DashboardComponent } from './dashboard/dashboard.component';
import { PrintLayoutComponent } from './print-layout/print-layout.component';
import { PrintMapComponent } from './print-layout/print-map/print-map.component';
import { PrintCodeComponent } from './print-layout/print-code/print-code.component';


const routes: Routes = [
    { path: 'help', loadChildren: './help/help.module#HelpModule' },
    { path: 'dashboard', component: DashboardComponent },
    { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
    {
        path: 'print',
        outlet: 'print',
        component: PrintLayoutComponent,
        children: [
            {
                path: 'map', component: PrintMapComponent
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
