import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { VBHelpComponent } from './vbhelp/vbhelp.component';
import { PythonHelpComponent } from './python-help/python-help.component';
import { JavaHelpComponent } from './java-help/java-help.component';
import { HelpTutorialJavaComponent } from './tutorial/help-tutorial-java/help-tutorial-java.component';
import { HelpTutorialVbComponent } from './tutorial/help-tutorial-vb/help-tutorial-vb.component';
import { HelpTutorialPythonComponent } from './tutorial/help-tutorial-python/help-tutorial-python.component';

const routes: Routes = [
  {
    path: 'java',
    component: JavaHelpComponent
  },
  {
    path: 'vb',
    component: VBHelpComponent
  },
  {
    path: 'python',
    component: PythonHelpComponent
  },
  {
    path: 'java/tutorial',
    component: HelpTutorialJavaComponent
  },
  {
    path: 'vb/tutorial',
    component: HelpTutorialVbComponent
  },
  {
    path: 'python/tutorial',
    component: HelpTutorialPythonComponent
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class HelpRoutingModule { }
