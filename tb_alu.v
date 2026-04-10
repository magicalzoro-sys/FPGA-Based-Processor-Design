`timescale 1ns/1ns
`include "alu.v"

module tb_alu;

    reg  [3:0]  opcode;
    reg  [7:0]  acc_in;
    reg  [7:0]  operand;
    wire [7:0]  acc_out;
    wire [15:0] extended_out;
    wire        c_b;

    alu uut (
        .opcode       (opcode),
        .acc_in       (acc_in),
        .operand      (operand),
        .acc_out      (acc_out),
        .extended_out (extended_out),
        .c_b          (c_b)
    );

    // 1) Waveform dump
    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, tb_alu);
    end

    // 2) Monitor header + continuous output
    initial begin
        opcode  = 4'bx;
        acc_in  = 8'hxx;
        operand = 8'hxx;
        $display("  Time\t |  Opcode  |  Acc_In  |  Operand |  Acc_Out |  Extended_Out    | C/B");
        $monitor("  %4t  |   %b |  %d     |  %d      |  %d      |  %d          |  %b",
                  $time, opcode, acc_in, operand, acc_out, extended_out, c_b);
    end

    // 3) Stimulus
    initial begin
        // --- Standard operands: acc=10, op=3 ---
        acc_in = 8'd10; operand = 8'd3;

        opcode = 4'b0001; #10; // ADD : 10+3  = 13,  c_b=0
        opcode = 4'b0010; #10; // SUB : 10-3  = 7,   c_b=0
        opcode = 4'b0011; #10; // MUL : 10*3  = 30,  extended_out=30
        opcode = 4'b0100; #10; // OR  : 10|3  = 11
        opcode = 4'b0101; #10; // AND : 10&3  = 2
        opcode = 4'b0110; #10; // XOR : 10^3  = 9
        opcode = 4'b0111; #10; // CMP : 10<3? = 0,   c_b=0
        opcode = 4'b1000; #10; // SHL : 10<<1 = 20,  c_b=0 (MSB of 10 = 0)
        opcode = 4'b1001; #10; // SHR : 10>>1 = 5,   c_b=0 (LSB of 10 = 0)

        // --- Carry/Borrow edge cases ---
        acc_in = 8'd255; operand = 8'd1;
        opcode = 4'b0001; #10; // ADD overflow : 255+1=256 → acc=0,  c_b=1

        acc_in = 8'd3; operand = 8'd10;
        opcode = 4'b0010; #10; // SUB borrow   : 3-10=-7  → borrow, c_b=1

        // --- CMP when acc < operand ---
        acc_in = 8'd5; operand = 8'd20;
        opcode = 4'b0111; #10; // CMP : 5<20? = 1,   c_b=1

        // --- MUL large values ---
        acc_in = 8'd200; operand = 8'd200;
        opcode = 4'b0011; #10; // MUL : 200*200 = 40000 (needs 16-bit)

        // --- SHL with MSB=1 → carry ---
        acc_in = 8'b1000_0001; operand = 8'd0;
        opcode = 4'b1000; #10; // SHL : MSB=1 → c_b=1, acc=0000_0010

        // --- SHR with LSB=1 → carry ---
        acc_in = 8'b0000_0011; operand = 8'd0;
        opcode = 4'b1001; #10; // SHR : LSB=1 → c_b=1, acc=0000_0001

        // --- Default (unknown opcode) ---
        opcode = 4'b1111; #10; // Default: pass-through

        $display("                                                            ");
        $display("  Simulation Complete.");
        $display("                                                            ");
        $finish;
    end

endmodule
