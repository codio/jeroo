export const VBMode: any = {
    start: [
        {
            regex: /sub|if|elseif|else|while/i,
            token: 'keyword',
            indent: true
        },
        {
            regex: /dim/i,
            token: 'keyword'
        },
        {
            regex: /end (sub|if|elseif|else|while)/i,
            token: 'keyword',
            dedent: true
        },
        {
            regex: /true|false|as|new|north|south|east|west|ahead|left|right|here/i,
            token: 'atom'
        },
        {
            regex: /[a-zA-Z][a-zA-Z0-9]*/,
            token: 'variable'
        },
        {
            regex: /[+-]?[0-9]+/,
            token: 'number'
        },
        {
            regex: /[-+=<>&|!]+/,
            token: 'operator'
        },
        {
            regex: /'.*/,
            token: 'comment'
        },
    ],
    meta: {
        lineComment: '\'',
        electricInput: /end.*/i
    }
};
