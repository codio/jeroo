import { Component, OnInit } from '@angular/core';

enum SelectedLanguage {
    Java,
    Vb,
    Python
}

function selectedLanguageToString(lang: SelectedLanguage) {
    if (lang === SelectedLanguage.Java) {
        return 'java';
    } else if (lang === SelectedLanguage.Vb) {
        return 'vb';
    } else if (lang === SelectedLanguage.Python) {
        return 'python';
    } else {
        throw new Error('Invalid Language');
    }
}

interface Language {
    value: SelectedLanguage;
    viewValue: string;
}

@Component({
    selector: 'app-dashboard',
    templateUrl: './dashboard.component.html',
    styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent implements OnInit {

    selectedLanguage = SelectedLanguage.Java;
    languages: Language[] = [
        { viewValue: 'JAVA/C++/C#', value: SelectedLanguage.Java },
        { viewValue: 'VB.NET', value: SelectedLanguage.Vb },
        { viewValue: 'PYTHON', value: SelectedLanguage.Python }
    ];

    constructor() { }

    ngOnInit() {
    }

    setSelectedLanguage(selectedLanguage: SelectedLanguage) {
        this.selectedLanguage = selectedLanguage;
    }

    getHelpUrl() {
        return `/help/${selectedLanguageToString(this.selectedLanguage)}`;
    }

    getTutorialUrl() {
        return `/help/${selectedLanguageToString(this.selectedLanguage)}/tutorial`;
    }
}
