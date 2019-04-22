import { Injectable } from '@angular/core';
import { MatrixService } from './matrix.service';
import { Jeroo } from './jeroo';
import { TileType } from './matrixConstants';
import { numberToRelativeDirection, numberToCardinalDirection } from './jerooConstants';
import { Subject } from 'rxjs';

export class RuntimeError extends Error {
    constructor(message: string, public line_num: number) {
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
    private jerooChangeSource = new Subject<Jeroo>();
    jerooChange$ = this.jerooChangeSource.asObservable();

    executeInstructionsUntilLNumChanges(instructions: Array<Instruction>, matrixService: MatrixService) {
        if (this.validInstruction(instructions)) {
            const prevInstruction = this.getCurrentInstruction(instructions);
            while (this.validInstruction(instructions)) {
                const currInstruction = this.getCurrentInstruction(instructions);
                if ((prevInstruction.f !== currInstruction.f) || (currInstruction.e !== prevInstruction.e)) {
                    break;
                }
                const instruction = this.fetchInstruction(instructions);
                this.executeBytecode(instruction, matrixService);
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
       * @param matService Matrix service.
       */
    executeBytecode(command: Instruction, matService: MatrixService) {
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
                const tile = matService.getTile(command.b + 1, command.c + 1);
                if (!matService.isInBounds(command.b + 1, command.c + 1) || tile === TileType.Water) {
                    throw new RuntimeError('INSTANTIATION ERROR: Jeroo started in the water', command.f);
                }
                if (tile === TileType.Net) {
                    throw new RuntimeError('INSTANTIATION ERROR: Jeroo started in a net', command.f);
                }
                if (matService.getJeroo(command.b + 1, command.c + 1) !== null) {
                    throw new RuntimeError('INSTANTIATION ERROR: Jeroo started on another Jeroo', command.f);
                }
                if (this.jerooArray.length >= 4) {
                    throw new RuntimeError('INSTANTIATION ERROR: Too many jeroos', command.f);
                }
                try {
                    const direction = numberToCardinalDirection(command.e);
                    const jeroo = new Jeroo(command.a, command.b + 1, command.c + 1, command.d, direction);
                    this.jerooArray[command.a] = jeroo;
                    matService.setJeroo(jeroo.getX(), jeroo.getY(), jeroo);
                } catch (e) {
                    throw new RuntimeError(e.message, command.f);
                }
                break;
            }
            case 'TURN': {
                const direction = numberToRelativeDirection(command.a);
                const jeroo = this.getCurrentJeroo();
                jeroo.turn(direction);
                this.jerooChangeSource.next(jeroo);
                break;
            }
            case 'HOP': {
                try {
                    const currentJeroo = this.getCurrentJeroo();
                    for (let n = 0; n < command.a; n++) {
                        currentJeroo.hop(matService);
                    }
                } catch (e) {
                    throw new RuntimeError(e.message, command.f);
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
            case 'GIVE': { // refacter with new jeroo and relational direction
                const direction = numberToRelativeDirection(command.a);
                this.getCurrentJeroo().give(direction, matService);
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
                const direction = numberToRelativeDirection(command.a);
                const isNet = this.getCurrentJeroo().isNet(direction, matService);
                this.cmpStack.push(isNet);
                break;
            }
            case 'ISWATER': {
                const direction = numberToRelativeDirection(command.a);
                const isWater = this.getCurrentJeroo().isWater(direction, matService);
                this.cmpStack.push(isWater);
                break;
            }
            case 'ISJEROO': {
                const direction = numberToRelativeDirection(command.a);
                const isJeroo = this.getCurrentJeroo().isJeroo(direction, matService);
                this.cmpStack.push(isJeroo);
                break;
            }
            case 'ISFLWR': {
                const direction = numberToRelativeDirection(command.a);
                const isFlower = this.getCurrentJeroo().isFlower(direction, matService);
                this.cmpStack.push(isFlower);
                break;
            }
            case 'FACING': {
                const direction = numberToCardinalDirection(command.a);
                const isFacing = this.getCurrentJeroo().isFacing(direction);
                this.cmpStack.push(isFacing);
                break;
            }
            case 'NOT': {
                const not = !this.cmpStack[this.cmpStack.length - 1];
                this.cmpStack.push(not);
                break;
            }
            case 'AND': {
                const x = this.cmpStack.pop();
                const y = this.cmpStack.pop();
                this.cmpStack.push(x && y);
                break;
            }
            case 'OR': {
                const x = this.cmpStack.pop();
                const y = this.cmpStack.pop();
                this.cmpStack.push(x || y);
                break;
            }
            case 'RETR': {
                this.pc = this.pcStack.pop();
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
