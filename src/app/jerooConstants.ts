export enum CardinalDirection {
    North,
    East,
    South,
    West
}

export function cardinalDirectionToNumber(direction: CardinalDirection) {
    if (direction === CardinalDirection.North) {
        return 0;
    } else if (direction === CardinalDirection.East) {
        return 1;
    } else if (direction === CardinalDirection.South) {
        return 2;
    } else if (direction === CardinalDirection.West) {
        return 3;
    } else {
        throw new Error('Unknown cardinal direction');
    }
}

export function numberToCardinalDirection(n: number) {
    if (n === 0) {
        return CardinalDirection.North;
    } else if (n === 1) {
        return CardinalDirection.East;
    } else if (n === 2) {
        return CardinalDirection.South;
    } else if (n === 3) {
        return CardinalDirection.West;
    } else {
        throw new Error('Unknown cardinal direction');
    }
}

export enum RelativeDirection {
    Ahead,
    Left,
    Right,
    Here
}

export function relativeDirectionToNumber(direction: RelativeDirection) {
    if (direction === RelativeDirection.Ahead) {
        return 0;
    } else if (direction === RelativeDirection.Left) {
        return 3;
    } else if (direction === RelativeDirection.Right) {
        return 1;
    } else if (direction === RelativeDirection.Here) {
        return -1;
    } else {
        throw new Error('Unknown relative direction');
    }
}

export function numberToRelativeDirection(n: number) {
    if (n === 0) {
        return RelativeDirection.Ahead;
    } else if (n === 3) {
        return RelativeDirection.Left;
    } else if (n === 1) {
        return RelativeDirection.Right;
    } else if (n === -1) {
        return RelativeDirection.Here;
    } else {
        throw new Error('Unknown relative direction');
    }
}

export interface Point {
    x: number;
    y: number;
}
