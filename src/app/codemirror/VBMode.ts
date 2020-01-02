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

export const VBMode: any = {
  start: [
    {
      regex: /sub|if|then|elseif|else|while/i,
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
