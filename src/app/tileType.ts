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

export enum TileType {
  Water = 'W',
  Grass = '.',
  Flower = 'F',
  Net = 'N'
}

export class TileTileUtil {
  /**
   * Convert a character to a TileType.
   * @param char character to convert.
   * @returns Converted tile.
   */
  public static stringToTileType(char: string) {
    if (char === TileType.Grass) {
      return TileType.Grass;
    } else if (char === TileType.Water) {
      return TileType.Water;
    } else if (char === TileType.Flower) {
      return TileType.Flower;
    } else if (char === TileType.Net) {
      return TileType.Net;
    } else {
      throw new Error('Invalid TileType in island');
    }
  }
}
