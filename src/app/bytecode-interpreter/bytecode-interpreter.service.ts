import { Injectable } from '@angular/core';
import { IslandService } from '../island.service';
import { Jeroo } from './jeroo';
import { TileType } from '../tileType';
import { Subject } from 'rxjs';

export class RuntimeError extends Error {
  constructor(message: string, public pane_num: number, public line_num: number) {
    super(message);
  }
}

@Injectable({
  providedIn: 'root'
})
export class BytecodeInterpreterService {
  private pc = 0;
  private jerooReg = 0;
  jerooArray: Array<Jeroo> = [];
  jerooMap: any = [];
  private cmpStack: Array<boolean> = [];
  private pcStack: Array<number> = [];
  private jerooChangeSource = new Subject<void>();
  jerooChange$ = this.jerooChangeSource.asObservable();

  executeInstructionsUntilLNumChanges(instructions: Array<Instruction>, islandService: IslandService) {
    if (this.validInstruction(instructions)) {
      const prevInstruction = this.getCurrentInstruction(instructions);
      while (this.validInstruction(instructions)) {
        const currInstruction = this.getCurrentInstruction(instructions);
        if ((prevInstruction.f !== currInstruction.f) || (currInstruction.e !== prevInstruction.e)) {
          break;
        }
        const instruction = this.fetchInstruction(instructions);
        this.executeBytecode(instruction, islandService);
      }
    }
  }

  validInstruction(instructions: Array<Instruction>) {
    return this.pc < instructions.length;
  }

  getCurrentInstruction(instructions: Array<Instruction>) {
    return instructions[this.pc];
  }

  /**
   * Reset the state of the bytecode interpreter, clear the board of jeroos, and re-render the board state to the canvas.
   */
  reset() {
    this.pc = 0;
    this.jerooReg = 0;
    this.jerooArray = [];
    this.jerooMap = [];
    this.cmpStack = [];
    this.pcStack = [];
  }

  /**
   * Fetch the next instruction from a sequence of instructions.
   * @param instructions The sequence of instructions.
   * @return The next instruction.
   */
  fetchInstruction(instructions: Array<Instruction>) {
    const instruction = instructions[this.pc];
    this.pc++;
    return instruction;
  }

  /**
   * Execute a given command.
   * @param command The given command.
   * @param matService Island service.
   */
  executeBytecode(command: Instruction, matService: IslandService) {
    switch (command.op) {
      case 'CSR': {
        this.jerooReg = command.a;
        break;
      }
      case 'JUMP': {
        this.pc = command.a;
        break;
      }
      case 'BZ': {
        if (!this.cmpStack[this.cmpStack.length - 1]) {
          this.pc = command.a;
        }
        break;
      }
      case 'NEW': {
        const row = command.b + 1;
        const col = command.c + 1;
        const tile = matService.getTile(col, row);
        if (!matService.isInBounds(col, row) || tile === TileType.Water) {
          throw new RuntimeError('INSTANTIATION ERROR: Jeroo started in the water', 0, command.f);
        }
        if (tile === TileType.Net) {
          throw new RuntimeError('INSTANTIATION ERROR: Jeroo started in a net', 0, command.f);
        }
        if (matService.getJeroo(col, row) !== null) {
          throw new RuntimeError('INSTANTIATION ERROR: Jeroo started on another Jeroo', 0, command.f);
        }
        if (this.jerooArray.length >= 4) {
          throw new RuntimeError('INSTANTIATION ERROR: Too many jeroos', 0, command.f);
        }
        try {
          const direction = command.e;
          const jeroo = new Jeroo(command.a, col, row, command.d, direction);
          if (tile === TileType.Flower) {
            jeroo.setInFlower(true);
          }

          this.jerooArray[command.a] = jeroo;
          matService.setJeroo(jeroo.getX(), jeroo.getY(), jeroo);
        } catch (e) {
          throw new RuntimeError(e.message, 0, command.f);
        }
        break;
      }
      case 'TURN': {
        const direction = command.a;
        const jeroo = this.getCurrentJeroo();
        jeroo.turn(direction);
        this.jerooChangeSource.next();
        break;
      }
      case 'HOP': {
        try {
          const currentJeroo = this.getCurrentJeroo();
          for (let n = 0; n < command.a; n++) {
            currentJeroo.hop(matService);
          }
        } catch (e) {
          throw new RuntimeError(e.message, command.e, command.f);
        } finally {
          this.jerooChangeSource.next();
        }
        break;
      }
      case 'TOSS': {
        this.getCurrentJeroo().toss(matService);
        break;
      }
      case 'PLANT': {
        this.getCurrentJeroo().plant(matService);
        break;
      }
      case 'GIVE': {
        const direction = command.a;
        this.getCurrentJeroo().give(direction, matService);
        break;
      }
      case 'PICK': {
        this.getCurrentJeroo().pick(matService);
        this.jerooChangeSource.next();
        break;
      }
      case 'TRUE': {
        this.cmpStack.push(true);
        break;
      }
      case 'FALSE': {
        this.cmpStack.push(false);
        break;
      }
      case 'HASFLWR': {
        const isFlower = this.getCurrentJeroo().hasFlower();
        this.cmpStack.push(isFlower);
        break;
      }
      case 'ISNET': {
        const direction = command.a;
        const isNet = this.getCurrentJeroo().isNet(direction, matService);
        this.cmpStack.push(isNet);
        break;
      }
      case 'ISWATER': {
        const direction = command.a;
        const isWater = this.getCurrentJeroo().isWater(direction, matService);
        this.cmpStack.push(isWater);
        break;
      }
      case 'ISJEROO': {
        const direction = command.a;
        const isJeroo = this.getCurrentJeroo().isJeroo(direction, matService);
        this.cmpStack.push(isJeroo);
        break;
      }
      case 'ISFLWR': {
        const direction = command.a;
        const isFlower = this.getCurrentJeroo().isFlower(direction, matService);
        this.cmpStack.push(isFlower);
        break;
      }
      case 'FACING': {
        const direction = command.a;
        const isFacing = this.getCurrentJeroo().isFacing(direction);
        this.cmpStack.push(isFacing);
        break;
      }
      case 'NOT': {
        const x = this.cmpStack.pop();
        if (x !== undefined) {
          const not = !x;
          this.cmpStack.push(not);
        }
        break;
      }
      case 'AND': {
        const x = this.cmpStack.pop();
        const y = this.cmpStack.pop();
        if (x !== undefined && y !== undefined) {
          this.cmpStack.push(x && y);
        }
        break;
      }
      case 'OR': {
        const x = this.cmpStack.pop();
        const y = this.cmpStack.pop();
        if (x !== undefined && y !== undefined) {
          this.cmpStack.push(x || y);
        }
        break;
      }
      case 'RETR': {
        const pc = this.pcStack.pop();
        if (pc !== undefined) {
          this.pc = pc;
        }
        break;
      }
      case 'CALLBK': {
        this.pcStack.push(this.pc + 1);
        break;
      }
      default: {
        throw new Error('Failed to run command: Invalid command at line ' + command.f);
      }
    }
  }

  getCurrentJeroo() {
    return this.jerooArray[this.jerooReg];
  }

  getPc() {
    return this.pc;
  }

  getJerooReg() {
    return this.jerooReg;
  }

  getCmpStack() {
    return this.cmpStack;
  }

  getJerooAtIndex(x: number) {
    return this.jerooArray[x];
  }
}
