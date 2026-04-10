`timescale 1ns/1ns
`include "accumulator.v"

module tb_accumulator_module;

    reg        clk;
    reg        rst;
    reg        load;
    reg  [7:0] acc_in;
    wire [7:0] acc_out;

    accumulator_module uut (
        .clk     (clk),
        .rst     (rst),
        .load    (load),
        .acc_in  (acc_in),
        .acc_out (acc_out)
    );

    // 1) Clock generation — 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 2) Waveform dump
    initial begin
        $dumpfile("accumulator.vcd");
        $dumpvars(0, tb_accumulator_module);
    end

    // 3) Monitor header + continuous output
    initial begin
        $display("  Time\t |  RST  |  LOAD  |  Acc_In  |  Acc_Out");
        $monitor("  %4t  |   %b   |   %b    |  %d      |  %d",
                  $time, rst, load, acc_in, acc_out);
    end

    // 4) Stimulus — all changes after posedge clk + 1ns to avoid setup violations
    initial begin
        rst = 1; load = 0; acc_in = 8'd0;
        @(posedge clk); #1;

        // --- Release reset ---
        rst = 0;
        @(posedge clk); #1;

        // --- Load 42 ---
        acc_in = 8'd42; load = 1;
        @(posedge clk); #1;     // acc_out should become 42

        // --- Hold: load=0, new value on bus but should NOT load ---
        load = 0; acc_in = 8'd99;
        @(posedge clk); #1;     // acc_out should still be 42

        // --- Load 99 ---
        load = 1;
        @(posedge clk); #1;     // acc_out should become 99

        // --- Load 200 ---
        acc_in = 8'd200;
        @(posedge clk); #1;     // acc_out should become 200

        // --- Hold again ---
        load = 0; acc_in = 8'd55;
        @(posedge clk); #1;     // acc_out should still be 200

        // --- Async reset while holding a value ---
        // rst fires mid-cycle — acc_out should go 0 immediately (async)
        rst = 1;
        #3;                     // async: does NOT wait for clock edge
        // acc_out must be 0 here already

        @(posedge clk); #1;
        rst = 0;

        // --- Load after reset ---
        acc_in = 8'd77; load = 1;
        @(posedge clk); #1;     // acc_out should become 77

        // --- Reset overrides load (rst=1 AND load=1 simultaneously) ---
        rst = 1; load = 1; acc_in = 8'd255;
        @(posedge clk); #1;     // acc_out must stay/go 0, reset wins

        load = 0; rst = 0;
        @(posedge clk); #1;

        $display("                                                            ");
        $display("  Simulation Complete.");
        $display("                                                            ");
        $finish;
    end

endmodule
