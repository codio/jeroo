export enum TileType {
  Water = 'W',
  Grass = '.',
  Flower = 'F',
  Net = 'N'
}

/**
 * Convert a character to a TileType.
 * @param char character to convert.
 * @returns Converted tile.
 */
export function stringToTileType(char: string) {
  if (char === TileType.Grass) {
    return TileType.Grass;
  } else if (char === TileType.Water) {
    return TileType.Water;
  } else if (char === TileType.Flower) {
    return TileType.Flower;
  } else if (char === TileType.Net) {
    return TileType.Net;
  } else {
    throw new Error('Invalid TileType in map');
  }
}
