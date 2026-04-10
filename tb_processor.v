`timescale 1ns/1ns
`include "processor.v"

module processor_tb;

    reg        clk;
    reg        en;
    wire       cb;
    wire [7:0] accum;

    processor sm_processor (
        .clk        (clk),
        .en         (en),
        .C_B        (cb),
        .accum_wire (accum)
    );

    // 1) Clock generation — 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 2) Waveform dump
    initial begin
        $dumpfile("processor.vcd");
        $dumpvars(0, processor_tb);
    end

    // 3) Monitor — shows PC, opcode, ACC, C/B each cycle
    initial begin
        $display("  Time\t |  EN  |  PC  |  Opcode  |  ACC (dec)  |  ACC (bin)   | C/B");
        $monitor("  %4t  |   %b  |  %d   |   %b  |     %d      |  %b  |  %b",
                  $time, en,
                  sm_processor.program_counter,
                  sm_processor.opcode,
                  accum, accum, cb);
    end

    // 4) Stimulus
    initial begin
        // --- Initialise: en=0 loads registers and resets state ---
        en = 0;
        @(negedge clk); #1;   // let init settle on negedge

        // --- Enable processor: begins fetching from PC=0 ---
        @(posedge clk); #1;
        en = 1;

        // --- Run for 12 cycles: 8 instructions + 4 HLT confirmation cycles ---
        repeat(12) @(posedge clk); #1;

        // --- Verify HLT: toggle en off then on, PC must restart from 0 ---
        en = 0;
        @(negedge clk); #1;
        @(posedge clk); #1;
        en = 1;
        repeat(5) @(posedge clk); #1;

        $display("                                                            ");
        $display("  Simulation Complete.");
        $display("                                                            ");
        $finish;
    end

endmodule
