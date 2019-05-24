import { MatrixService } from './matrix.service';
import { TileType } from './jerooTileType';
import {
  Point,
  CardinalDirection,
  RelativeDirection
} from './jerooDirection';

const STEP: Point[] = [
  // north
  {
    x: 0,
    y: -1
  },
  // east
  {
    x: 1,
    y: 0
  },
  // south
  {
    x: 0,
    y: 1
  },
  // west
  {
    x: -1,
    y: 0
  }
];

export class Jeroo {
  private inWater = false;
  private inNet = false;
  private inFlower = false;
  private inJeroo = false;
  /**
   * Create a new Jeroo
   * @param id A unique numerical identifier for this jeroo.
   * @param x The column number that this jeroo is at.
   * @param y The row number that this jeroo is at.
   * @param numFlowers The number of flowers this jeroo has.
   * @param direction The direction this jeroo is facing.
   */
  constructor(private id: number,
              private x: number,
              private y: number,
              private numFlowers: number,
              private direction: CardinalDirection
             ) {
    if (numFlowers < 0) {
      throw new Error('INSTANTIATION ERROR: flowers < 0');
    }

    if (direction < 0 || direction > 3) {
      throw new Error('INSTANTIATION ERROR: The direction is invalid');
    }
  }

  /**
   * Get this jeroo's id
   * @return this jeroo's id
   */
  getId() {
    return this.id;
  }

  /**
   * Get this jeroo's column number.
   * @return This jeroo's column number.
   */
  getX() {
    return this.x;
  }

  /**
   * Get this jeroo's row number.
   * @return this jeroo's row number.
   */
  getY() {
    return this.y;
  }

  /**
   * Get this jeroo's number of flowers.
   * @return this jeroo's number of flowers.
   */
  getNumFlowers() {
    return this.numFlowers;
  }

  /**
   * Get the direction this jeroo is facing.
   * @return this jeroo's direction.
   */
  getDirection() {
    return this.direction;
  }

  /**
   * Turn this jeroo by a direction.
   * @param turnDir The direction to turn.
   */
  turn(turnDir: RelativeDirection) {
    const turnDirNum = turnDir;
    let myDirNum = this.direction;
    myDirNum = (myDirNum + turnDirNum) % 4;
    this.direction = myDirNum;
  }

  /**
   * Move the jeroo ahead by one space.
   * @param matrixService Matrix service.
   */
  hop(matrixService: MatrixService) {
    const nextLocation = this.getLocation(RelativeDirection.Ahead);
    const nextTile = matrixService.getTile(nextLocation.x, nextLocation.y);
    matrixService.setJeroo(this.getX(), this.getY(), null);
    this.x = nextLocation.x;
    this.y = nextLocation.y;

    const nextJeroo = matrixService.getJeroo(nextLocation.x, nextLocation.y);
    if (nextJeroo) {
      nextJeroo.setInJeroo(true);
      this.inJeroo = true;
      this.inWater = false;
      this.inNet = false;
      this.inFlower = false;
      throw new Error('LOGIC ERROR: Jeroo has collided with another jeroo');
    }
    matrixService.setJeroo(this.getX(), this.getY(), this);
    if (nextTile === TileType.Flower) {
      this.inFlower = true;
      this.inWater = false;
      this.inNet = false;
      this.inJeroo = false;
    } else {
      this.inFlower = false;
    }
    if (!matrixService.isInBounds(nextLocation.x, nextLocation.y)) {
      this.inWater = true;
      this.inNet = false;
      this.inFlower = false;
      this.inJeroo = false;
      throw new Error('LOGIC ERROR: Jeroo is out of bounds');
    }
    if (nextTile === TileType.Water) {
      this.inWater = true;
      this.inNet = false;
      this.inFlower = false;
      this.inJeroo = false;
      throw new Error('LOGIC ERROR: Jeroo is on water');
    }
    if (nextTile === TileType.Net) {
      this.inNet = true;
      this.inWater = false;
      this.inFlower = false;
      this.inJeroo = false;
      throw new Error('LOGIC ERROR: Jeroo is on a net');
    }
  }

  /**
   * Toss a flower ahead of this current jeroo.
   * If the flower hits a net, that net is destroyed.
   * If this jeroo has no flowers, this does nothing.
   * @param matrixService Matrix service.
   */
  toss(matrixService: MatrixService) {
    if (this.numFlowers > 0) {
      this.numFlowers--;
      const nextLocation = this.getLocation(RelativeDirection.Ahead);
      const nextTile = matrixService.getTile(nextLocation.x, nextLocation.y);
      if (nextTile === TileType.Net) {
        matrixService.setDynamicTile(nextLocation.x, nextLocation.y, TileType.Grass);
      }
    }
  }

  /**
   * Plant a flower at this jeroo's current location.
   * If this jeroo has no flowers, this does nothing.
   * @param matrixService Matrix service.
   */
  plant(matrixService: MatrixService) {
    if (this.numFlowers > 0) {
      this.numFlowers--;
      matrixService.setDynamicTile(this.x, this.y, TileType.Flower);
    }
  }


  /**
   * Give a flower to a jeroo in a given direction.
   * If there is no jeroo in the direction or this jeroo has no flowers, this command does nothing.
   * @param direction The direction to look for a jeroo.
   * @param matrixService Matrix service.
   */
  give(direction: RelativeDirection, matrixService: MatrixService) {
    if (this.numFlowers > 0) {
      const neighborLocation = this.getLocation(direction);
      const neighborJeroo = matrixService.getJeroo(neighborLocation.x, neighborLocation.y);
      if (neighborJeroo !== null) {
        this.numFlowers--;
        neighborJeroo.acceptFlower();
      }
    }
  }

  private acceptFlower() {
    this.numFlowers++;
  }

  pick(matrixService: MatrixService) {
    const tile = matrixService.getTile(this.x, this.y);
    if (tile === TileType.Flower) {
      this.numFlowers++;
      this.inFlower = false;
      this.inWater = false;
      this.inNet = false;
      matrixService.setDynamicTile(this.x, this.y, TileType.Grass);
    }
  }

  /**
   * Test if this jeroo has flowers.
   * @return The result of the test.
   */
  hasFlower() {
    return this.numFlowers > 0;
  }

  /**
   * Test if there is a net in a given direction.
   * @param lookDirection The direction to look for a net.
   * @param matrixService Matrix service.
   * @return The result of the test.
   */
  isNet(lookDirection: RelativeDirection, matrixService: MatrixService) {
    const location = this.getLocation(lookDirection);
    return matrixService.getTile(location.x, location.y) === TileType.Net;
  }

  /**
   * Test if there is water in a given direction.
   * @param lookDirection The direction to look for water.
   * @param matrixService Matrix service.
   * @return The result of the test.
   */
  isWater(lookDirection: RelativeDirection, matrixService: MatrixService) {
    const location = this.getLocation(lookDirection);
    return matrixService.getTile(location.x, location.y) === TileType.Water;
  }

  /**
   * Test if there is a jeroo in a given direction.
   * @param lookDirection The direction to look for a jeroo.
   * @param matrixService Matrix service.
   * @return The result of the test.
   */
  isJeroo(lookDirection: RelativeDirection, matrixService: MatrixService) {
    const location = this.getLocation(lookDirection);
    return matrixService.getJeroo(location.x, location.y) !== null;
  }

  isFlower(lookDirection: RelativeDirection, matrixService: MatrixService) {
    const location = this.getLocation(lookDirection);
    return matrixService.getTile(location.x, location.y) === TileType.Flower;
  }

  isFacing(direction: CardinalDirection) {
    return this.direction === direction;
  }

  private getLocation(direction: RelativeDirection): Point {
    const directionNum = direction;
    const myDirectionNum = this.direction;
    const lookDirection = (directionNum + myDirectionNum) % 4;
    const dx = STEP[lookDirection].x;
    const dy = STEP[lookDirection].y;

    return {
      x: this.x + dx,
      y: this.y + dy
    };
  }

  isInWater() {
    return this.inWater;
  }

  isInNet() {
    return this.inNet;
  }

  isInFlower() {
    return this.inFlower;
  }

  setInFlower(val: boolean) {
    this.inFlower = val;
  }

  isInJeroo() {
    return this.inJeroo;
  }

  setInJeroo(val: boolean) {
    this.inJeroo = val;
  }
}
