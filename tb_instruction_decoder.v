`timescale 1ns/1ns
`include "design.v"

module tb_instruction_decoder;

    reg  [7:0] instruction;
    wire [3:0] opcode;
    wire [3:0] reg_add;

    instruction_decoder uut (
        .instruction_code (instruction),
        .opcode           (opcode),
        .reg_add          (reg_add)
    );

    initial begin
        $dumpfile("instruction_decoder.vcd");
        $dumpvars(0, tb_instruction_decoder);
    end

    initial begin
        instruction = 8'bx;   // initialise to X so monitor shows clean start
        $display("  Time\t |  Instruction    |  Opcode   |  Reg_Addr");
        $monitor("  %4t   |   %b      |   %b    |   %b   ",
                  $time, instruction, opcode, reg_add);
    end

    initial begin
        // Test 1: opcode=1101 (13) | reg=0010 (2)
        instruction = 8'b1101_0010; #10;
        // Test 2: opcode=0001 (1)  | reg=1110 (14)
        instruction = 8'b0001_1110; #10;
        // Test 3: opcode=0100 (4)  | reg=1101 (13)
        instruction = 8'b0100_1101; #10;
        // Test 4: All zeros
        instruction = 8'b0000_0000; #10;
        // Test 5: All ones
        instruction = 8'b1111_1111; #10;
        // Test 6: Alternating pattern
        instruction = 8'b1010_0101; #10;
        
        $display("                                                            ");
        $display("  Simulation Complete.");
        $display("                                                            ");
        $finish;
    end

endmodule