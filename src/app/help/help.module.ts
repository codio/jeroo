import { NgModule } from '@angular/core';
import { MaterialModule } from '../material.module';

import { JavaHelpComponent } from './java-help/java-help.component';
import { HelpConditionJavaComponent } from './java-help/help-condition-java/help-condition-java.component';
import { HelpControlStructJavaComponent } from './java-help/help-control-struct-java/help-control-struct-java.component';
import { HelpGeneralJavaComponent } from './java-help/help-general-java/help-general-java.component';
import { HelpInstantiationJavaComponent } from './java-help/help-instantiation-java/help-instantiation-java.component';
import { HelpMethodJavaComponent } from './java-help/help-method-java/help-method-java.component';
import { PythonHelpComponent } from './python-help/python-help.component';
import { HelpConditionPythonComponent } from './python-help/help-condition-python/help-condition-python.component';
import { HelpControlStructPythonComponent } from './python-help/help-control-struct-python/help-control-struct-python.component';
import { HelpGeneralPythonComponent } from './python-help/help-general-python/help-general-python.component';
import { HelpInstantiationPythonComponent } from './python-help/help-instantiation-python/help-instantiation-python.component';
import { HelpMethodPythonComponent } from './python-help/help-method-python/help-method-python.component';
import { VBHelpComponent } from './vbhelp/vbhelp.component';
import { HelpConditionVBComponent } from './vbhelp/help-condition-vb/help-condition-vb.component';
import { HelpControlStructVBComponent } from './vbhelp/help-control-struct-vb/help-control-struct-vb.component';
import { HelpGeneralVbComponent } from './vbhelp/help-general-vb/help-general-vb.component';
import { HelpInstantiationVbComponent } from './vbhelp/help-instantiation-vb/help-instantiation-vb.component';
import { HelpMethodVbComponent } from './vbhelp/help-method-vb/help-method-vb.component';
import { HelpActionComponent } from './general/help-action/help-action.component';
import { HelpBooleanComponent } from './general/help-boolean/help-boolean.component';
import { HelpCompassComponent } from './general/help-compass/help-compass.component';
import { HelpDirectionsComponent } from './general/help-directions/help-directions.component';
import { HelpRelativeComponent } from './general/help-relative/help-relative.component';
import { HelpTutorialJavaComponent } from './tutorial/help-tutorial-java/help-tutorial-java.component';
import { HelpTutorialPythonComponent } from './tutorial/help-tutorial-python/help-tutorial-python.component';
import { HelpTutorialVbComponent } from './tutorial/help-tutorial-vb/help-tutorial-vb.component';
import { HelpRoutingModule } from './help-routing.module';
import { CommonModule } from '@angular/common';

@NgModule({
    declarations: [
        JavaHelpComponent,
        HelpConditionJavaComponent,
        HelpControlStructJavaComponent,
        HelpGeneralJavaComponent,
        HelpInstantiationJavaComponent,
        HelpMethodJavaComponent,
        PythonHelpComponent,
        HelpConditionPythonComponent,
        HelpControlStructPythonComponent,
        HelpGeneralPythonComponent,
        HelpInstantiationPythonComponent,
        HelpMethodPythonComponent,
        VBHelpComponent,
        HelpConditionVBComponent,
        HelpControlStructVBComponent,
        HelpGeneralVbComponent,
        HelpInstantiationVbComponent,
        HelpMethodVbComponent,
        HelpActionComponent,
        HelpBooleanComponent,
        HelpCompassComponent,
        HelpDirectionsComponent,
        HelpRelativeComponent,
        HelpTutorialJavaComponent,
        HelpTutorialPythonComponent,
        HelpTutorialVbComponent
    ],
    imports: [
        HelpRoutingModule,
        CommonModule,
        MaterialModule
    ],
    exports: [
        JavaHelpComponent,
        HelpConditionJavaComponent,
        HelpControlStructJavaComponent,
        HelpGeneralJavaComponent,
        HelpInstantiationJavaComponent,
        HelpMethodJavaComponent,
        PythonHelpComponent,
        HelpConditionPythonComponent,
        HelpControlStructPythonComponent,
        HelpGeneralPythonComponent,
        HelpInstantiationPythonComponent,
        HelpMethodPythonComponent,
        VBHelpComponent,
        HelpConditionVBComponent,
        HelpControlStructVBComponent,
        HelpGeneralVbComponent,
        HelpInstantiationVbComponent,
        HelpMethodVbComponent,
        HelpActionComponent,
        HelpBooleanComponent,
        HelpCompassComponent,
        HelpDirectionsComponent,
        HelpRelativeComponent,
        HelpTutorialJavaComponent,
        HelpTutorialPythonComponent,
        HelpTutorialVbComponent
    ]
})
export class HelpModule { }
