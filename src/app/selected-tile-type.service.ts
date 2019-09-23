import { Injectable } from '@angular/core';
import { TileType } from './tileType';

@Injectable({
  providedIn: 'root'
})
export class SelectedTileTypeService {
  selectedTileType: TileType = TileType.Grass;

  constructor() { }
}
