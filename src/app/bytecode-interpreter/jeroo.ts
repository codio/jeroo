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

import { IslandService } from '../island.service';
import { TileType } from '../tileType';
import {
  Point,
  CardinalDirection,
  RelativeDirection
} from './direction';

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
   * @param islandService Island service.
   */
  hop(islandService: IslandService) {
    const nextLocation = this.getLocation(RelativeDirection.Ahead);
    const nextTile = islandService.getTile(nextLocation.x, nextLocation.y);
    islandService.setJeroo(this.getX(), this.getY(), null);
    this.x = nextLocation.x;
    this.y = nextLocation.y;

    const nextJeroo = islandService.getJeroo(nextLocation.x, nextLocation.y);
    if (nextJeroo) {
      nextJeroo.setInJeroo(true);
      this.inJeroo = true;
      this.inWater = false;
      this.inNet = false;
      this.inFlower = false;
      throw new Error('LOGIC ERROR: Jeroo has collided with another jeroo');
    }
    islandService.setJeroo(this.getX(), this.getY(), this);
    if (nextTile === TileType.Flower) {
      this.inFlower = true;
      this.inWater = false;
      this.inNet = false;
      this.inJeroo = false;
    } else {
      this.inFlower = false;
    }
    if (!islandService.isInBounds(nextLocation.x, nextLocation.y)) {
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
   * @param islandService Island service.
   */
  toss(islandService: IslandService) {
    if (this.numFlowers > 0) {
      this.numFlowers--;
      const nextLocation = this.getLocation(RelativeDirection.Ahead);
      const nextTile = islandService.getTile(nextLocation.x, nextLocation.y);
      if (nextTile === TileType.Net) {
        islandService.setDynamicTile(nextLocation.x, nextLocation.y, TileType.Grass);
      }
    }
  }

  /**
   * Plant a flower at this jeroo's current location.
   * If this jeroo has no flowers, this does nothing.
   * @param islandService Island service.
   */
  plant(islandService: IslandService) {
    if (this.numFlowers > 0) {
      this.numFlowers--;
      islandService.setDynamicTile(this.x, this.y, TileType.Flower);
    }
  }


  /**
   * Give a flower to a jeroo in a given direction.
   * If there is no jeroo in the direction or this jeroo has no flowers, this command does nothing.
   * @param direction The direction to look for a jeroo.
   * @param islandService Island service.
   */
  give(direction: RelativeDirection, islandService: IslandService) {
    if (this.numFlowers > 0) {
      const neighborLocation = this.getLocation(direction);
      const neighborJeroo = islandService.getJeroo(neighborLocation.x, neighborLocation.y);
      if (neighborJeroo !== null) {
        this.numFlowers--;
        neighborJeroo.acceptFlower();
      }
    }
  }

  private acceptFlower() {
    this.numFlowers++;
  }

  pick(islandService: IslandService) {
    const tile = islandService.getTile(this.x, this.y);
    if (tile === TileType.Flower) {
      this.numFlowers++;
      this.inFlower = false;
      this.inWater = false;
      this.inNet = false;
      islandService.setDynamicTile(this.x, this.y, TileType.Grass);
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
   * @param islandService Island service.
   * @return The result of the test.
   */
  isNet(lookDirection: RelativeDirection, islandService: IslandService) {
    const location = this.getLocation(lookDirection);
    return islandService.getTile(location.x, location.y) === TileType.Net;
  }

  /**
   * Test if there is water in a given direction.
   * @param lookDirection The direction to look for water.
   * @param islandService Island service.
   * @return The result of the test.
   */
  isWater(lookDirection: RelativeDirection, islandService: IslandService) {
    const location = this.getLocation(lookDirection);
    return islandService.getTile(location.x, location.y) === TileType.Water;
  }

  /**
   * Test if there is a jeroo in a given direction.
   * @param lookDirection The direction to look for a jeroo.
   * @param islandService Island service.
   * @return The result of the test.
   */
  isJeroo(lookDirection: RelativeDirection, islandService: IslandService) {
    const location = this.getLocation(lookDirection);
    return islandService.getJeroo(location.x, location.y) !== null;
  }

  isFlower(lookDirection: RelativeDirection, islandService: IslandService) {
    const location = this.getLocation(lookDirection);
    return islandService.getTile(location.x, location.y) === TileType.Flower;
  }

  isFacing(direction: CardinalDirection) {
    return this.direction === direction;
  }

  private getLocation(direction: RelativeDirection): Point {
    if (direction === RelativeDirection.Here) {
      return {
        x: this.x,
        y: this.y
      };
    }
    const lookDirection = (direction + this.direction) % 4;
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
