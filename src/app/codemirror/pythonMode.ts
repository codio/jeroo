export const pythonMode: any = {
  start: [
    {
      regex: /while|if/,
      token: 'keyword'
    },
    {
      regex: /def|else|elif/,
      token: 'keyword',
      dedent: true
    },
    {
      regex: /True|False|and|or|not|self|NORTH|SOUTH|EAST|WEST|AHEAD|LEFT|RIGHT|HERE/,
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
      regex: /:/,
      indent: true
    },
    {
      regex: /#.*/,
      token: 'comment'
    },
    {
      regex: /"""/,
      token: 'comment',
      next: 'comment'
    }
  ],
  comment: [
    {
      regex: /.*?"""/,
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
    lineComment: '#',
    electricInput: /else|elif|def/
  }
};
