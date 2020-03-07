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

import { TestBed } from '@angular/core/testing';
import { Jeroo } from './bytecode-interpreter/jeroo';
import { CardinalDirection } from './bytecode-interpreter/direction';
import { TileType } from './tileType';
import { IslandService } from './island.service';

describe('IslandService', () => {

  beforeEach(() => TestBed.configureTestingModule({}));

  it('get and set correctly find entities', () => {
    const service = TestBed.inject(IslandService);
    service.setStaticTile(1, 1, TileType.Water);
    expect(service.getTile(1, 1)).toBe(TileType.Water);
  });

  it('get and set jeroo gets and sets a jeroo', () => {
    const service = TestBed.inject(IslandService);
    const jeroo = new Jeroo(0, 1, 1, 1, CardinalDirection.East);
    service.setJeroo(1, 1, jeroo);
    expect(service.getJeroo(1, 1)).toBe(jeroo);
  });

  it('assert getTile prioritizes dynamic map', () => {
    const service = TestBed.inject(IslandService);
    service.setDynamicTile(0, 0, TileType.Water);
    service.setStaticTile(0, 0, TileType.Net);
    expect(service.getTile(0, 0)).toBe(TileType.Water);
  });

  it('reset map resets map', () => {
    const service = TestBed.inject(IslandService);
    service.setStaticTile(1, 1, TileType.Water);
    service.resetIsland();
    expect(service.getTile(1, 1)).toBe(TileType.Grass);
  });

  it('reset jeroos resets the jeroo array', () => {
    const service = TestBed.inject(IslandService);
    const jeroo = new Jeroo(0, 1, 1, 1, CardinalDirection.East);
    service.setJeroo(1, 1, jeroo);
    service.resetJeroos();
    expect(service.getJeroo(1, 1)).toBeNull();
  });

  it('toString correctly converts map to a string', () => {
    const service = TestBed.inject(IslandService);
    service.setStaticTile(6, 6, TileType.Water);
    service.setStaticTile(2, 3, TileType.Flower);
    service.setStaticTile(24, 24, TileType.Net);

    const actual = service.toString();
    const expected =
      '........................\n' +
      '........................\n' +
      '.F......................\n' +
      '........................\n' +
      '........................\n' +
      '.....W..................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '.......................N\n';
    expect(actual).toBe(expected);
  });

  it('genMapFromString correctly loads a map from a string', () => {
    const service = TestBed.inject(IslandService);
    const map =
      'W......................W\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........NNN.............\n' +
      '........FFF.............\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      '........................\n' +
      'W......................W\n';
    service.genIslandFromString(map);
    const lines = map.trim().split('\n');
    for (let row = 0; row < lines.length; row++) {
      for (let col = 0; col < lines[0].length; col++) {
        const actual = service.getTile(col + 1, row + 1);
        const expected = lines[row].charAt(col);
        if (actual === null) {
          throw new Error('Tile must not be null');
        }
        expect(actual).toBe(expected);
      }
    }
  });

  it('genMapFromString correctly adjusts size of map', () => {
    const service = TestBed.inject(IslandService);
    const map =
      '.....\n' +
      '.....\n' +
      '.....\n';
    service.genIslandFromString(map);
    expect(service.getCols()).toBe(7);
    expect(service.getRows()).toBe(5);
  });

  it('genMapFromString throws error on unknown TileType', () => {
    const service = TestBed.inject(IslandService);
    const oldRows = service.getRows();
    const oldCols = service.getCols();
    const map =
      '.XYZW\n' +
      '...GG\n';
    expect(() => service.genIslandFromString(map)).toThrow(new Error('Invalid TileType in island'));
    expect(service.getRows()).toBe(oldRows);
    expect(service.getCols()).toBe(oldCols);
  });

  it('genMapFromString throws error on jagged map', () => {
    const service = TestBed.inject(IslandService);
    const oldRows = service.getRows();
    const oldCols = service.getCols();
    const map =
      '.....\n' +
      '..\n';
    expect(() => service.genIslandFromString(map)).toThrow(new Error('Jagged maps are not allowed'));
    expect(service.getRows()).toBe(oldRows);
    expect(service.getCols()).toBe(oldCols);
  });

  it('genMapFromString empty string creates empty map', () => {
    const service = TestBed.inject(IslandService);
    const map = '';
    service.genIslandFromString(map);
    expect(service.getCols()).toBe(0);
    expect(service.getRows()).toBe(0);
  });

  it('genMapFromString sets map size correctly', () => {
    const service = TestBed.inject(IslandService);
    service.setRows(30);
    service.setCols(20);
    const map = service.toString();
    service.setRows(24);
    service.setCols(24);
    service.genIslandFromString(map);
    expect(service.getRows()).toBe(30);
    expect(service.getCols()).toBe(20);
  });
});
