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
