import { TestBed } from '@angular/core/testing';

import { MatrixService } from './matrix.service';

describe('MatrixService', () => {

  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    expect(service).toBeTruthy();
  });

  // generateBoard(xSize: number, ySize: number)
  // drawBoard()
  // getMatrix()
  it('should create the base array and return with getMatrix', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    service.drawBoard();
    expect(service.getMatrix()).toEqual([[ 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W',
                                          'W', 'W', 'W', 'W', 'W', 'W', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G',
                                          'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W',
                                          'W', 'W', 'W', 'W', 'W', 'W', 'W' ]]);
  });

  // getWidthSize()
  it('widthSize should be returned with getWidthSize', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    // will always default to size 26
    expect(service.getWidthSize()).toEqual(26);
  });

  // setWidthSize(wSize: number)
  it('widthSize should change with setWidthSize', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    service.setWidthSize(15);
    expect(service.getWidthSize()).toEqual(15);
  });

  // getHeightSize()
  it('heightSize should be returned with getHeightSize', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    // will always default to size 26
    expect(service.getHeightSize()).toEqual(26);
  });

  // setHeightSize(hSize: number)
  it('heightSize should change with setHeightSize', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    service.setHeightSize(15);
    expect(service.getHeightSize()).toEqual(15);
  });

  // getMaxXSize()
  it('getMaxXSize should return the maxXSize', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    // maxXSize will default to 25 (widthSize - 1)
    expect(service.getMaxXSize()).toEqual(25);
  });

  // setMaxXSize()
  it('setMaxXSize should set a new maxXSize', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    service.setWidthSize(43);
    // should be set to 42 (widthSize - 1)
    service.setMaxXSize();
    expect(service.getMaxXSize()).toEqual(42);
  });

  // getMaxYSize()
  it('getMaxYSize should return the maxYSize', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    // maxYSize will default to 25 (heightSize - 1)
    expect(service.getMaxYSize()).toEqual(25);
  });

  // setMaxYSize()
  it('setMaxYSize should set a new maxYSize', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    service.setHeightSize(43);
    // should be set to 42 (widthSize - 1)
    service.setMaxYSize();
    expect(service.getMaxYSize()).toEqual(42);
  });

  // getCurrentValue()
  it('should get a current value for editing', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    // default value for editing is 'W'
    expect(service.getCurrentValue()).toEqual('W');
  });

  // setCurrentValue(newValue: string)
  it('should set a new current value for editing', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    service.setCurrentValue('N');
    expect(service.getCurrentValue()).toEqual('N');
  });

  // getWaterType()
  it('should return proper waterType from getWaterType', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    expect(service.getWaterType()).toEqual('W');
  });

  // getGrassType()
  it('should return proper grassType from getGrassType', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    expect(service.getGrassType()).toEqual('G');
  });

  // getFlowerType()
  it('should return proper flowerType from getFlowerType', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    expect(service.getFlowerType()).toEqual('F');
  });

  // getNetType()
  it('should return proper netType from getNetType', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    expect(service.getNetType()).toEqual('N');
  });

  // getClearType()
  it('should return proper clearType from getClearType', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    expect(service.getClearType()).toEqual('C');
  });

  // getBoardValueAt(row: number, column: number)
  it('should return the value at a specific spot in the matrix', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    service.drawBoard();
    // should be water on default board
    expect(service.getBoardValueAt(0, 1)).toEqual('W');
    // should be grass on default board
    expect(service.getBoardValueAt(4, 15)).toEqual('G');
  });

  // setBoardValueAt(row: number, column: number)
  it('should set the value at a specific spot in the matrix to currentValue', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    service.drawBoard();
    service.setBoardValueAt(5, 14);
    // current value defaults to water
    expect(service.getBoardValueAt(5, 14)).toEqual('W');
    service.setCurrentValue('N');
    service.setBoardValueAt(3, 23);
    expect(service.getBoardValueAt(3, 23)).toEqual('N');
  });

  it('should create an array of any size (1 - 50)', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    service.setWidthSize(3);
    service.setHeightSize(7);
    service.setMaxXSize();
    service.setMaxYSize();
    service.drawBoard();
    expect(service.getMatrix()).toEqual([[ 'W', 'W', 'W' ],
                                         [ 'W', 'G', 'W' ],
                                         [ 'W', 'G', 'W' ],
                                         [ 'W', 'G', 'W' ],
                                         [ 'W', 'G', 'W' ],
                                         [ 'W', 'G', 'W' ],
                                         [ 'W', 'W', 'W' ]]);
  });

  it('should all work together to create and edit the matrix', () => {
    const service: MatrixService = TestBed.get(MatrixService);
    service.drawBoard();
    service.setWidthSize(14);
    service.setHeightSize(14);
    service.setMaxXSize();
    service.setMaxYSize();
    service.drawBoard();
    service.setCurrentValue(service.getNetType());
    service.setBoardValueAt(4, 7);
    service.setBoardValueAt(4, 8);
    service.setCurrentValue(service.getFlowerType());
    service.setBoardValueAt(12, 2);
    expect(service.getMatrix()).toEqual([[ 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'N', 'N', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'G', 'F', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'G', 'W' ],
                                         [ 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W', 'W' ]]);
  });

});
