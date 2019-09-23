export enum CardinalDirection {
  North = 0,
  East = 1,
  South = 2,
  West = 3
}

export enum RelativeDirection {
  Ahead = 0,
  Left = 3,
  Right = 1,
  Here = -1
}

export interface Point {
  x: number;
  y: number;
}
