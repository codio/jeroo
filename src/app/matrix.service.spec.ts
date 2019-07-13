import { TestBed } from '@angular/core/testing';
import { Jeroo } from './jeroo';
import { CardinalDirection } from './jerooDirection';
import { TileType } from './jerooTileType';
import { MatrixService } from './matrix.service';

describe('MatrixService', () => {

  beforeEach(() => TestBed.configureTestingModule({}));

  it('get and set correctly find entities', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    service.setStaticTile(1, 1, TileType.Water);
    expect(service.getTile(1, 1)).toBe(TileType.Water);
  });

  it('get and set jeroo gets and sets a jeroo', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    const jeroo = new Jeroo(0, 1, 1, 1, CardinalDirection.East);
    service.setJeroo(1, 1, jeroo);
    expect(service.getJeroo(1, 1)).toBe(jeroo);
  });

  it('assert getTile prioritizes dynamic map', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    service.setDynamicTile(0, 0, TileType.Water);
    service.setStaticTile(0, 0, TileType.Net);
    expect(service.getTile(0, 0)).toBe(TileType.Water);
  });

  it('reset map resets map', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    service.setStaticTile(1, 1, TileType.Water);
    service.resetMap();
    expect(service.getTile(1, 1)).toBe(TileType.Grass);
  });

  it('reset jeroos resets the jeroo array', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    const jeroo = new Jeroo(0, 1, 1, 1, CardinalDirection.East);
    service.setJeroo(1, 1, jeroo);
    service.resetJeroos();
    expect(service.getJeroo(1, 1)).toBeNull();
  });

  it('toString correctly converts map to a string', () => {
    const service: MatrixService = TestBed.get(MatrixService);
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
    const service: MatrixService = TestBed.get(MatrixService);
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
    service.genMapFromString(map);
    const lines = map.trim().split('\n');
    for (let row = 0; row < lines.length; row++) {
      for (let col = 0; col < lines[0].length; col++) {
        const actual = service.getTile(col + 1, row + 1);
        const expected = lines[row].charAt(col);
        expect(actual).toBe(expected);
      }
    }
  });

  it('genMapFromString correctly adjusts size of map', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    const map =
      '.....\n' +
      '.....\n' +
      '.....\n';
    service.genMapFromString(map);
    expect(service.getCols()).toBe(7);
    expect(service.getRows()).toBe(5);
  });

  it('genMapFromString throws error on unknown TileType', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    const oldRows = service.getRows();
    const oldCols = service.getCols();
    const map =
      '.XYZW\n' +
      '...GG\n';
    expect(() => service.genMapFromString(map)).toThrow(new Error('Invalid TileType in map'));
    expect(service.getRows()).toBe(oldRows);
    expect(service.getCols()).toBe(oldCols);
  });

  it('genMapFromString throws error on jagged map', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    const oldRows = service.getRows();
    const oldCols = service.getCols();
    const map =
      '.....\n' +
      '..\n';
    expect(() => service.genMapFromString(map)).toThrow(new Error('Jagged maps are not allowed'));
    expect(service.getRows()).toBe(oldRows);
    expect(service.getCols()).toBe(oldCols);
  });

  it('genMapFromString empty string creates empty map', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    const map = '';
    service.genMapFromString(map);
    expect(service.getCols()).toBe(0);
    expect(service.getRows()).toBe(0);
  });

  it('genMapFromString sets map size correctly', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    service.setRows(30);
    service.setCols(20);
    const map = service.toString();
    service.setRows(24);
    service.setCols(24);
    service.genMapFromString(map);
    expect(service.getRows()).toBe(30);
    expect(service.getCols()).toBe(20);
  });
});
