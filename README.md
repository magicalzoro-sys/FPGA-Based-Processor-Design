# 8-Bit FPGA Processor in Verilog

## Overview
This repository contains the Verilog RTL implementation of a simple, custom 8-bit processor designed for FPGA deployment. The processor features a modular architecture, complete with an instruction decoder, register file, ALU, accumulator, and control logic. It is designed as an educational model to demonstrate fundamental computer architecture concepts and digital logic design.

## Architecture Highlights
[cite_start]The processor is built using a modular design approach, with a top-level `processor` module integrating the following sub-components [cite: 319-437]:

* [cite_start]**Instruction Decoder (`instruction_decoder`):** Parses an 8-bit instruction code, splitting it into a 4-bit opcode (bits 7:4) and a 4-bit register address (bits 3:0) [cite: 4-9].
* **Register File (`register_file`):** Provides memory storage using 16 separate 8-bit registers. [cite_start]It supports read and write operations based on the active clock edge and write-enable signals [cite: 35-39].
* **Arithmetic Logic Unit (`alu`):** The computational core of the processor. [cite_start]It supports basic arithmetic (ADD, SUB), 16-bit multiplication (MUL), logical operations (OR, AND, XOR), comparisons (CMP), and bitwise shifts (SHL, SHR) [cite: 101-117]. [cite_start]It outputs an 8-bit result, a 16-bit extended result, and a carry/borrow flag [cite: 93-95].
* [cite_start]**Accumulator (`accumulator_module`):** An 8-bit register that temporarily holds operational data and interfaces directly with the ALU [cite: 198-206, 466].
* [cite_start]**Control Logic (`control_logic`):** Manages the execution flow by controlling a 4-bit Program Counter (PC) [cite: 264-265]. [cite_start]It handles standard sequential execution as well as branching based on control signals [cite: 266-273].

## Instruction Set Architecture (ISA)
The processor uses a 4-bit opcode, allowing for a variety of instructions. [cite_start]Based on the integrated top-level module, the following operations are supported [cite: 365-434]:

### Primary Operations
| Opcode (Binary) | Instruction | Description |
| :--- | :--- | :--- |
| `0001` | ADD | Add register value to Accumulator |
| `0010` | SUB | Subtract register value from Accumulator |
| `0011` | MUL | Multiply register value by Accumulator |
| `0101` | AND | Logical AND register value with Accumulator |
| `0110` | XRA | Logical XOR register value with Accumulator |
| `0111` | CMP | Compare Accumulator with register value |
| `1000` | BR | Branch to 4-bit address if carry/borrow flag is set |
| `1001` | MOV ACC, Ri | Move value from Register to Accumulator |
| `1010` | MOV Ri, ACC | Move value from Accumulator to Register |
| `1011` | RET | Return to address |
| `1111` | HLT | Halt execution |

### Miscellaneous Operations (Opcode `0000`)
[cite_start]When the opcode is `0000`, the 4-bit register address field acts as an extended opcode for specific Accumulator manipulations [cite: 412-423]:
* `0000`: NOP (No Operation)
* `0001`: LSL (Logical Shift Left)
* `0010`: LSR (Logical Shift Right)
* `0011`: CIR (Circular Shift Right)
* `0100`: CIL (Circular Shift Left)
* `0101`: ASR (Arithmetic Shift Right)
* `0110`: INC (Increment Accumulator)
* `0111`: DEC (Decrement Accumulator)

## Simulation and Testing
To ensure the reliability of the design, dedicated testbenches are provided for every individual module, as well as the top-level processor. 

[cite_start]The top-level `processor_tb` initializes a sequence of instructions pre-loaded into the registers, simulating memory, and steps through the execution cycles [cite: 342-358, 440-457].

### Running Simulations
You can run the provided testbenches using any standard Verilog simulator, such as:
* Vivado
* ModelSim / Questa
* Icarus Verilog (iverilog)

**Example using Icarus Verilog:**
```bash
iverilog -o processor_sim processor.v processor_tb.v
vvp processor_sim
