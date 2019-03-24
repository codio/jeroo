import { Injectable } from '@angular/core';
import { MatrixService } from './matrix.service';
import { Jeroo } from './jeroo';
import { TileType } from './matrixConstants';
import { numberToRelativeDirection, numberToCardinalDirection } from './jerooConstants';


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
    private instructions: Array<Instruction>;
    private jerooArray: Array<Jeroo> = [];
    private cmpStack: Array<boolean> = [];
    private pcStack: Array<number> = [];
    private instructionSpeed = 0;
    private paused = false;
    private stopped = false;

    /**
       * Execute a given sequence of instructions continuously and update the matrix board to reflect the game.
       * @param instructions The sequence of instructions.
       * @param matrixService Matrix board.
       * @param canvas Rendering canvas.
       * @param endInstructionsCallback callback function for when the instructions are finished executing.
       */
    executeInstructionsContinious(
        instructions: Array<Instruction>,
        matrixService: MatrixService,
        canvas: CanvasRenderingContext2D,
        endInstructionsCallback: () => void
    ) {
        this.reset(matrixService, canvas);
        this.instructions = instructions;
        this.resumeExecutionContinious(matrixService, canvas, endInstructionsCallback);
    }

    /**
       * Execute the first instruction in a sequence of instructions, update the matrix board, then pause the game.
       * @param instructions The sequence of instructions.
       * @param matrixService Matrix board.
       * @param canvas Rendering canvas.
       * @param postInstructionCallback callback function for when an instruction finished executing.
       * @param endInstructionsCallback callback function for when the instructions are finished executing.
       */
    executeInstructionsStepwise(
        instructions: Array<Instruction>,
        matrixService: MatrixService,
        canvas: CanvasRenderingContext2D,
        postInstructionCallback: () => void,
        endInstructionsCallback: () => void
    ) {
        this.reset(matrixService, canvas);
        this.instructions = instructions;
        this.resumeExecutionStepwise(matrixService, canvas, postInstructionCallback, endInstructionsCallback);
    }

    /**
      * Resume execution of the previous instruction set after a pause then pause after executing one instruction.
      * @param matrixService Matrix board.
      * @param canvas Rendering canvas.
      * @param endInstructionsCallback callback function for when the instructions are finished executing.
      */
    resumeExecutionContinious(matrixService: MatrixService, canvas: CanvasRenderingContext2D, endInstructionsCallback: () => void) {
        this.paused = false;
        const executeInstruction = () => {
            const line_num = this.instructions[this.pc].f;
            while (true) {
                if (!this.validInstruction()) {
                    endInstructionsCallback();
                    break;
                }
                const current_line_num = this.instructions[this.pc].f;
                if (line_num !== current_line_num) {
                    setTimeout(executeInstruction, this.instructionSpeed);
                    break;
                }
                if (this.stopped || this.paused) {
                    break;
                }
                const instruction = this.fetchInstruction();
                this.executeBytecode(instruction, matrixService);
                matrixService.render(canvas);
            }
        };
        setTimeout(executeInstruction, this.instructionSpeed);
    }

    /**
      * Resume execution of the previous instruction set after a pause.
      * @param matrixService Matrix board.
      * @param canvas Rendering canvas.
      * @param postInstructionCallback callback function for after each instruction is done executing.
      * @param endInstructionsCallback callback function for when the instructions are finished executing.
      */
    resumeExecutionStepwise(
        matrixService: MatrixService,
        canvas: CanvasRenderingContext2D,
        postInstructionCallback: () => void,
        endInstructionsCallback: () => void
    ) {
        const line_num = this.instructions[this.pc].f;
        this.paused = false;
        const executeInstruction = () => {
            while (true) {
                if (!this.validInstruction()) {
                    endInstructionsCallback();
                    break;
                }
                const current_line_num = this.instructions[this.pc].f;
                if (line_num !== current_line_num) {
                    this.pauseExecution();
                    postInstructionCallback();
                    break;
                }
                if (this.stopped || this.paused) {
                    break;
                }
                const instruction = this.fetchInstruction();
                this.executeBytecode(instruction, matrixService);
                matrixService.render(canvas);
            }
        };

        setTimeout(executeInstruction, this.instructionSpeed);
    }

    private validInstruction() {
        return this.pc < this.instructions.length;
    }

    /**
      * Pause the execution of the instructions.
      */
    pauseExecution() {
        this.paused = true;
    }

    /**
      * Clear the previously stored instructions and stop execution.
      */
    stopExecution() {
        this.instructions = [];
        this.stopped = true;
    }

    /**
      * Reset the state of the bytecode interpreter, clear the board of jeroos, and re-render the board state to the canvas.
      * @param matrixService Matrix service.
      * @param canvas Rendering canvas.
      */
    reset(matrixService: MatrixService, canvas: CanvasRenderingContext2D) {
        this.pc = 0;
        this.jerooReg = 0;
        this.jerooArray = [];
        this.cmpStack = [];
        this.pcStack = [];
        this.paused = false;
        this.stopped = false;
        matrixService.resetJeroos();
        matrixService.render(canvas);
    }

    setInstructionSpeed(instructionSpeed: number) {
        this.instructionSpeed = instructionSpeed;
    }

    /**
       * Fetch the next instruction from a sequence of instructions.
       * @param instructions The sequence of instructions.
       * @return The next instruction.
       */
    fetchInstruction() {
        const instruction = this.instructions[this.pc];
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
                const tile = matService.getTile(command.b, command.c);
                if (tile === TileType.Water) {
                    throw new RuntimeError('INSTANTIATION ERROR: Jeroo started in the water', command.f);
                }
                if (tile === TileType.Net) {
                    throw new RuntimeError('INSTANTIATION ERROR: Jeroo started in a net', command.f);
                }
                if (matService.getJeroo(command.b, command.c) !== null) {
                    throw new RuntimeError('INSTANTIATION ERROR: Jeroo started on another Jeroo', command.f);
                }
                if (this.jerooArray.length >= 4) {
                    throw new RuntimeError('INSTANTIATION ERROR: Too many jeroos', command.f);
                }
                try {
                    const direction = numberToCardinalDirection(command.e);
                    const jeroo = new Jeroo(command.a, command.b, command.c, command.d, direction);
                    this.jerooArray.push(jeroo);
                    matService.setJeroo(jeroo.getX(), jeroo.getY(), jeroo);
                } catch (e) {
                    throw new RuntimeError(e.message, command.f);
                }
                break;
            }
            case 'TURN': {
                const direction = numberToRelativeDirection(command.a);
                this.getCurrentJeroo().turn(direction);
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
}
