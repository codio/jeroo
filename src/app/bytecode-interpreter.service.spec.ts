import { TestBed } from '@angular/core/testing';

import { BytecodeInterpreterService, RuntimeError } from './bytecode-interpreter.service';
import { MatrixService } from './matrix.service';
import { Jeroo } from './jeroo';
import { TileType } from './matrixConstants';
import { CardinalDirection } from './jerooConstants';

describe('BytecodeInterpreterService', () => {
    beforeEach(() => TestBed.configureTestingModule({}));

    it('assert jump jumps to correct address', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const jump = newInstruction('JUMP', 2, 0, 0, 0, 0, 0);
        service.executeBytecode(jump, matService);
        expect(service.getPc()).toBe(2);
    });

    it('assert bz jumps after false', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const falseInstr = newInstruction('FALSE', 0, 0, 0, 0, 0, 0);
        service.executeBytecode(falseInstr, matService);
        const bz = newInstruction('BZ', 2, 0, 0, 0, 0, 0);
        service.executeBytecode(bz, matService);
        expect(service.getPc()).toBe(2);
    });

    it('assert bz does not jump after true', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const falseInstr = newInstruction('TRUE', 0, 0, 0, 0, 0, 0);
        service.executeBytecode(falseInstr, matService);
        const bz = newInstruction('BZ', 2, 0, 0, 0, 0, 0);
        service.executeBytecode(bz, matService);
        expect(service.getPc()).toBe(0);
    });

    it('assert csr changes jeroo register', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const csr = newInstruction('CSR', 3, 0, 0, 0, 0, 0);
        service.executeBytecode(csr, matService);
        expect(service.getJerooReg()).toBe(3);
    });

    it('assert new creates a new jeroo', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 0, 0, 0, 0, 0);
        service.executeBytecode(newInstr, matService);
        const expected = new Jeroo(0, 1, 1, 0, 0);
        expect(service.getCurrentJeroo()).toEqual(expected);
    });

    it('assert new with negative flowers throws error', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 0, 0, -1, 0, 0);
        expect(() => service.executeBytecode(newInstr, matService))
            .toThrow(new RuntimeError('INSTANTIATION ERROR: flowers < 0', 0));
    });

    it('assert new with invalid direction throws error', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 0, 0, 0, 8, 0);
        expect(() => service.executeBytecode(newInstr, matService))
            .toThrow(new RuntimeError('Unknown cardinal direction', 0));
    });

    it('assert new on water throws error', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        matService.setTile(3, 4, TileType.Water);
        const newInstr = newInstruction('NEW', 0, 2, 3, 0, 0, 0);
        expect(() => service.executeBytecode(newInstr, matService))
            .toThrow(new RuntimeError('INSTANTIATION ERROR: Jeroo started in the water', 0));
    });

    it('assert new outside of bounds throws error', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 50, -8, 0, 0, 0);
        expect(() => service.executeBytecode(newInstr, matService))
            .toThrow(new RuntimeError('INSTANTIATION ERROR: Jeroo started in the water', 0));
    });

    it('assert new on net throws error', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        matService.setTile(6, 3, TileType.Net);
        const newInstr = newInstruction('NEW', 0, 5, 2, 0, 0, 0);
        expect(() => service.executeBytecode(newInstr, matService))
            .toThrow(new RuntimeError('INSTANTIATION ERROR: Jeroo started in a net', 0));
    });

    it('assert new jeroo on another jeroo throws error', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr1 = newInstruction('NEW', 0, 1, 1, 0, 0, 0);
        const newInstr2 = newInstruction('NEW', 1, 1, 1, 0, 0, 0);

        service.executeBytecode(newInstr1, matService);
        expect(() => service.executeBytecode(newInstr2, matService))
            .toThrow(new RuntimeError('INSTANTIATION ERROR: Jeroo started on another Jeroo', 0));
    });

    it('assert new jeroo fails on too many jeroos', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr1 = newInstruction('NEW', 0, 1, 2, 0, 0, 0);
        const newInstr2 = newInstruction('NEW', 1, 1, 3, 0, 0, 0);
        const newInstr3 = newInstruction('NEW', 2, 1, 4, 0, 0, 0);
        const newInstr4 = newInstruction('NEW', 3, 1, 5, 0, 0, 0);
        const newInstr5 = newInstruction('NEW', 4, 1, 6, 0, 0, 0);

        service.executeBytecode(newInstr1, matService);
        service.executeBytecode(newInstr2, matService);
        service.executeBytecode(newInstr3, matService);
        service.executeBytecode(newInstr4, matService);
        expect(() => service.executeBytecode(newInstr5, matService))
            .toThrow(new RuntimeError('INSTANTIATION ERROR: Too many jeroos', 0));
    });

    it('assert turn turns the jeroo', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 0, 0, 0, 0, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const turnInstr = newInstruction('TURN', 1, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(turnInstr, matService);
        expect(service.getCurrentJeroo().getDirection()).toBe(CardinalDirection.East);
    });

    it('assert hop hops the jeroo', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 1, 0, 0, 1, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const turnInstr = newInstruction('HOP', 3, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(turnInstr, matService);
        const currentJeroo = service.getCurrentJeroo();
        expect(currentJeroo.getX()).toBe(5);
        expect(currentJeroo.getY()).toBe(1);
        expect(matService.getJeroo(5, 1)).toBe(currentJeroo);
    });

    it('assert hopping on a flower increases flower count', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        matService.setTile(2, 3, TileType.Flower);
        const newInstr = newInstruction('NEW', 0, 1, 1, 0, 2, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const turnInstr = newInstruction('HOP', 1, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(turnInstr, matService);
        const currentJeroo = service.getCurrentJeroo();
        expect(currentJeroo.getNumFlowers()).toBe(1);
    });

    it('assert hopping on a net throws error', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        matService.setTile(2, 3, TileType.Net);
        const newInstr = newInstruction('NEW', 0, 1, 1, 0, 2, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const turnInstr = newInstruction('HOP', 1, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        expect(() => service.executeBytecode(turnInstr, matService))
            .toThrow(new RuntimeError('LOGIC ERROR: Jeroo is on a net', 0));
    });

    it('assert hopping on water throws error', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        matService.setTile(2, 3, TileType.Water);
        const newInstr = newInstruction('NEW', 0, 1, 1, 0, 2, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const turnInstr = newInstruction('HOP', 1, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        expect(() => service.executeBytecode(turnInstr, matService))
            .toThrow(new RuntimeError('LOGIC ERROR: Jeroo is on water', 0));
    });

    it('assert hopping on another jeroo throws error', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const jeroo = new Jeroo(1, 1, 2, 0, 0);
        matService.setJeroo(2, 3, jeroo);
        const newInstr = newInstruction('NEW', 0, 1, 1, 0, 2, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const turnInstr = newInstruction('HOP', 1, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        expect(() => service.executeBytecode(turnInstr, matService))
            .toThrow(new RuntimeError('LOGIC ERROR: Jeroo has collided with another jeroo', 0));
    });

    it('assert toss decreases flower count', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 1, 1, 1, 2, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const tossInstr = newInstruction('TOSS', 0, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(tossInstr, matService);

        const currentJeroo = service.getCurrentJeroo();
        expect(currentJeroo.getNumFlowers()).toBe(0);
    });

    it('assert toss destroys a net', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        matService.setTile(2, 3, TileType.Net);
        const newInstr = newInstruction('NEW', 0, 1, 1, 1, 2, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const tossInstr = newInstruction('TOSS', 0, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(tossInstr, matService);

        expect(matService.getTile(2, 3)).toBe(TileType.Grass);
    });

    it('assert tossing flower with no flowers does nothing', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        matService.setTile(1, 2, TileType.Net);
        const newInstr = newInstruction('NEW', 0, 1, 1, 0, 2, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const tossInstr = newInstruction('TOSS', 0, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(tossInstr, matService);

        const currentJeroo = service.getCurrentJeroo();
        expect(currentJeroo.getNumFlowers()).toBe(0);
        expect(matService.getTile(1, 2)).toBe(TileType.Net);
    });

    it('assert plant plants a flower at the jeroo\'s location', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 1, 1, 1, 2, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const plantInstr = newInstruction('PLANT', 0, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(plantInstr, matService);

        const currentJeroo = service.getCurrentJeroo();
        expect(currentJeroo.getNumFlowers()).toBe(0);
        expect(matService.getTile(2, 2)).toBe(TileType.Flower);
    });

    it('assert plant with no flowers does nothing', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 1, 1, 0, 2, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const plantInstr = newInstruction('PLANT', 0, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(plantInstr, matService);

        const currentJeroo = service.getCurrentJeroo();
        expect(currentJeroo.getNumFlowers()).toBe(0);
        expect(matService.getTile(1, 1)).toBe(TileType.Grass);
    });

    it('assert give to ahead jeroo increases flower count', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 1, 1, 1, 2, 0);
        const neighborJerooInstr = newInstruction('NEW', 1, 0, 1, 0, 0, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const giveInstr = newInstruction('GIVE', 1, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(neighborJerooInstr, matService);
        service.executeBytecode(giveInstr, matService);

        const currentJeroo = service.getCurrentJeroo();
        expect(currentJeroo.getNumFlowers()).toBe(0);
        const neighborJeroo = matService.getJeroo(1, 2);
        expect(neighborJeroo.getNumFlowers()).toBe(1);
    });

    it('assert give to empty does nothing', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 1, 1, 1, 2, 0);
        const neighborJerooInstr = newInstruction('NEW', 1, 2, 1, 0, 0, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const giveInstr = newInstruction('GIVE', 1, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(neighborJerooInstr, matService);
        service.executeBytecode(giveInstr, matService);

        const currentJeroo = service.getCurrentJeroo();
        expect(currentJeroo.getNumFlowers()).toBe(1);
        const neighborJeroo = matService.getJeroo(3, 2);
        expect(neighborJeroo.getNumFlowers()).toBe(0);
    });

    it('assert give with no flowers does nothing', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 1, 1, 0, 2, 0);
        const neighborJerooInstr = newInstruction('NEW', 1, 0, 1, 0, 0, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const giveInstr = newInstruction('GIVE', 1, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(neighborJerooInstr, matService);
        service.executeBytecode(giveInstr, matService);

        const currentJeroo = service.getCurrentJeroo();
        expect(currentJeroo.getNumFlowers()).toBe(0);
        const neighborJeroo = matService.getJeroo(1, 2);
        expect(neighborJeroo.getNumFlowers()).toBe(0);
    });

    it('assert hasFlower with 1 flower returns true', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 1, 1, 1, 2, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const hasFlwrInstr = newInstruction('HASFLWR', 0, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(hasFlwrInstr, matService);

        const cmpStack = service.getCmpStack();
        const head = cmpStack[cmpStack.length - 1];
        expect(head).toBe(true);
    });

    it('assert hasFlower with 0 flowers return false', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 1, 1, 0, 2, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const hasFlwrInstr = newInstruction('HASFLWR', 0, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(hasFlwrInstr, matService);

        const cmpStack = service.getCmpStack();
        const head = cmpStack[cmpStack.length - 1];
        expect(head).toBe(false);
    });

    it('assert true pushes 1 to the stack', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const trueInstr = newInstruction('TRUE', 0, 0, 0, 0, 0, 0);

        service.executeBytecode(trueInstr, matService);

        const cmpStack = service.getCmpStack();
        const head = cmpStack[cmpStack.length - 1];
        expect(head).toBe(true);
    });

    it('assert false pushes 0 to the stack', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const falseInstr = newInstruction('FALSE', 0, 0, 0, 0, 0, 0);

        service.executeBytecode(falseInstr, matService);

        const cmpStack = service.getCmpStack();
        const head = cmpStack[cmpStack.length - 1];
        expect(head).toBe(false);
    });

    it('assert isNet pushes 1 to the stack if there is a net', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        matService.setTile(1, 2, TileType.Net);
        const newInstr = newInstruction('NEW', 0, 1, 1, 0, 2, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const isNetInstr = newInstruction('ISNET', 1, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(isNetInstr, matService);

        const cmpStack = service.getCmpStack();
        const head = cmpStack[cmpStack.length - 1];
        expect(head).toBe(true);
    });

    it('assert isNet pushes 0 to the stack if there is no net', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 1, 1, 0, 2, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const isNetInstr = newInstruction('ISNET', 1, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(isNetInstr, matService);

        const cmpStack = service.getCmpStack();
        const head = cmpStack[cmpStack.length - 1];
        expect(head).toBe(false);
    });

    it('assert isWater pushes true to the stack if there is water', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        matService.setTile(1, 2, TileType.Water);
        const newInstr = newInstruction('NEW', 0, 1, 1, 0, 2, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const isWaterInstr = newInstruction('ISWATER', 1, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(isWaterInstr, matService);

        const cmpStack = service.getCmpStack();
        const head = cmpStack[cmpStack.length - 1];
        expect(head).toBe(true);
    });

    it('assert isWater pushes 0 to the stack if there is no water', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 1, 1, 0, 2, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const isWaterInstr = newInstruction('ISWATER', 1, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(isWaterInstr, matService);

        const cmpStack = service.getCmpStack();
        const head = cmpStack[cmpStack.length - 1];
        expect(head).toBe(false);
    });

    it('assert isJeroo pushes 1 to the stack if there is a jeroo', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 1, 1, 0, 2, 0);
        const neighborJerooInstr = newInstruction('NEW', 1, 0, 1, 0, 0, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const isJerooInstr = newInstruction('ISJEROO', 1, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(neighborJerooInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(isJerooInstr, matService);

        const cmpStack = service.getCmpStack();
        const head = cmpStack[cmpStack.length - 1];
        expect(head).toBe(true);
    });

    it('assert isJeroo pushes 0 to the stack if there is no jeroo', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const newInstr = newInstruction('NEW', 0, 1, 1, 0, 2, 0);
        const csrInstr = newInstruction('CSR', 0, 0, 0, 0, 0, 0);
        const isJerooInstr = newInstruction('ISJEROO', 1, 0, 0, 0, 0, 0);

        service.executeBytecode(newInstr, matService);
        service.executeBytecode(csrInstr, matService);
        service.executeBytecode(isJerooInstr, matService);

        const cmpStack = service.getCmpStack();
        const head = cmpStack[cmpStack.length - 1];
        expect(head).toBe(false);
    });

    it('assert not negates the top of the stack', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const trueInstr = newInstruction('TRUE', 0, 0, 0, 0, 0, 0);
        const notInstr = newInstruction('NOT', 0, 0, 0, 0, 0, 0);

        service.executeBytecode(trueInstr, matService);
        service.executeBytecode(notInstr, matService);

        const cmpStack = service.getCmpStack();
        const head = cmpStack[cmpStack.length - 1];
        expect(head).toBe(false);
    });

    it('assert and and\'s two booleans', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const trueInstr1 = newInstruction('TRUE', 0, 0, 0, 0, 0, 0);
        const trueInstr2 = newInstruction('FALSE', 0, 0, 0, 0, 0, 0);
        const andInstr = newInstruction('AND', 0, 0, 0, 0, 0, 0);

        service.executeBytecode(trueInstr1, matService);
        service.executeBytecode(trueInstr2, matService);
        service.executeBytecode(andInstr, matService);

        const cmpStack = service.getCmpStack();
        const head = cmpStack[cmpStack.length - 1];
        expect(head).toBe(false);
    });

    it('assert or or\'s two booleans', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const trueInstr1 = newInstruction('TRUE', 0, 0, 0, 0, 0, 0);
        const trueInstr2 = newInstruction('FALSE', 0, 0, 0, 0, 0, 0);
        const orInstr = newInstruction('OR', 0, 0, 0, 0, 0, 0);

        service.executeBytecode(trueInstr1, matService);
        service.executeBytecode(trueInstr2, matService);
        service.executeBytecode(orInstr, matService);

        const cmpStack = service.getCmpStack();
        const head = cmpStack[cmpStack.length - 1];
        expect(head).toBe(true);
    });

    it('assert callbk and retr sets the PC correctly', () => {
        const service: BytecodeInterpreterService = TestBed.get(BytecodeInterpreterService);
        const matService: MatrixService = TestBed.get(MatrixService);
        const instructions = [
            newInstruction('JUMP', 3, 0, 0, 0, 0, 0),
            newInstruction('HOP', 1, 0, 0, 0, 0, 0),
            newInstruction('RETR', 0, 0, 0, 0, 0, 0),
            newInstruction('NEW', 0, 1, 1, 0, 0, 0),
            newInstruction('CSR', 0, 0, 0, 0, 0, 0),
            newInstruction('CALLBK', 0, 0, 0, 0, 0, 0),
            newInstruction('JUMP', 1, 0, 0, 0, 0, 0)
        ];

        service.executeInstructionsUntilLNumChanges(instructions, matService);

        const currJeroo = service.getCurrentJeroo();
        expect(matService.getJeroo(2, 1)).toEqual(currJeroo);
    });
});

function newInstruction(
    op: string,
    a: number,
    b: number,
    c: number,
    d: number,
    e: number,
    f: number): Instruction {
    return {
        op: op,
        a: a,
        b: b,
        c: c,
        d: d,
        e: e,
        f: f
    };
}
