import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { JavaHelpComponent } from './help/java-help/java-help.component';
import { VBHelpComponent } from './help/vbhelp/vbhelp.component';
import { PythonHelpComponent } from './help/python-help/python-help.component';
import { HelpTutorialJavaComponent } from './help/tutorial/help-tutorial-java/help-tutorial-java.component';
import { HelpTutorialVbComponent } from './help/tutorial/help-tutorial-vb/help-tutorial-vb.component';
import { HelpTutorialPythonComponent } from './help/tutorial/help-tutorial-python/help-tutorial-python.component';

const routes: Routes = [
    { path: 'help/java', component: JavaHelpComponent },
    { path: 'help/java/tutorial', component: HelpTutorialJavaComponent },
    { path: 'help/vb', component: VBHelpComponent },
    { path: 'help/vb/tutorial', component: HelpTutorialVbComponent },
    { path: 'help/python', component: PythonHelpComponent },
    { path: 'help/python/tutorial', component: HelpTutorialPythonComponent }
];

@NgModule({
    imports: [RouterModule.forRoot(routes)],
    exports: [RouterModule]
})
export class AppRoutingModule { }
