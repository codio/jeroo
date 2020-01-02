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
