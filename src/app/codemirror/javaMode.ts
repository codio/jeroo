export const javaMode: any = {
    start: [
        {
            regex: /method|while|if|else/,
            token: 'keyword'
        },
        {
            regex: /true|false|new|NORTH|SOUTH|EAST|WEST|AHEAD|LEFT|RIGHT|HERE/,
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
            regex: /[\{\(]/,
            indent: true
        },
        {
            regex: /[\}\)]/,
            dedent: true
        },
        {
            regex: /\/\/.*/,
            token: 'comment'
        },
        {
            regex: /\/\*/,
            token: 'comment',
            next: 'comment'
        }
    ],
    comment: [
        {
            regex: /.*?\*\//,
            token: 'comment',
            next: 'start'
        },
        {
            regex: /.*/,
            token: 'comment'
        }
    ],
    meta: {
        dontIndentStates: ['comment'],
        lineComment: '//'
    }
};
