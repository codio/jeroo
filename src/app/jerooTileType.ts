const waterType = 'W';
const grassType = '.';
const flowerType = 'F';
const netType = 'N';

export enum TileType {
    Water,
    Grass,
    Flower,
    Net
}

/**
 * Convert a character to a TileType.
 * @param char character to convert.
 * @returns Converted tile.
 */
export function stringToTileType(char: string) {
    if (char === grassType) {
        return TileType.Grass;
    } else if (char === waterType) {
        return TileType.Water;
    } else if (char === flowerType) {
        return TileType.Flower;
    } else if (char === netType) {
        return TileType.Net;
    } else {
        throw new Error('Invalid TileType in map');
    }
}

/**
 * Converts a TileType to a string
 * @param tileType tileType to convert
 * @returns string representation of a TileType
 */
export function tileTypeToString(tileType: TileType) {
    if (tileType === TileType.Grass) {
        return grassType;
    } else if (tileType === TileType.Water) {
        return waterType;
    } else if (tileType === TileType.Flower) {
        return flowerType;
    } else if (tileType === TileType.Net) {
        return netType;
    } else {
        throw new Error('Invalid TileType');
    }
}
