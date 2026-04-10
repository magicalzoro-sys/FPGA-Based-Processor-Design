`timescale 1ns/1ns
`include "control_logic.v"

module tb_control_logic;

    reg        clk;
    reg        rst;
    reg        branch;
    reg  [3:0] branch_addr;
    wire [3:0] pc;

    control_logic uut (
        .clk         (clk),
        .rst         (rst),
        .branch      (branch),
        .branch_addr (branch_addr),
        .pc          (pc)
    );

    // 1) Clock generation — 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 2) Waveform dump
    initial begin
        $dumpfile("control_logic.vcd");
        $dumpvars(0, tb_control_logic);
    end

    // 3) Monitor header + continuous output
    initial begin
        $display("  Time\t |  RST  |  BRANCH  |  Branch_Addr  |  PC");
        $monitor("  %4t  |   %b   |    %b     |      %d       |   %d",
                  $time, rst, branch, branch_addr, pc);
    end

    // 4) Stimulus — all driven after posedge clk + 1ns
    initial begin
        rst = 1; branch = 0; branch_addr = 4'd0;
        @(posedge clk); #1;

        // --- Release reset: PC starts incrementing from 0 ---
        rst = 0;
        repeat(4) @(posedge clk); #1;  // PC: 0 → 1 → 2 → 3 → 4

        // --- Branch to address 5 ---
        branch = 1; branch_addr = 4'd5;
        @(posedge clk); #1;             // PC → 5

        // --- Resume sequential increment from branch target ---
        branch = 0;
        repeat(4) @(posedge clk); #1;  // PC: 5 → 6 → 7 → 8 → 9

        // --- Branch to address 12 ---
        branch = 1; branch_addr = 4'd12;
        @(posedge clk); #1;             // PC → 12

        branch = 0;
        repeat(3) @(posedge clk); #1;  // PC: 12 → 13 → 14 → 15

        // --- PC wrap-around: 4-bit PC rolls over 15 → 0 ---
        @(posedge clk); #1;             // PC: 15 → 0 (wrap)
        repeat(2) @(posedge clk); #1;  // PC: 0 → 1 → 2

        // --- Branch to addr 0 (explicit jump to start) ---
        branch = 1; branch_addr = 4'd0;
        @(posedge clk); #1;             // PC → 0

        branch = 0;
        repeat(3) @(posedge clk); #1;  // PC: 0 → 1 → 2 → 3

        // --- Async reset mid-run: PC must go 0 immediately ---
        rst = 1;
        #3;                             // async: fires before next clock edge
        // PC must be 0 here already

        @(posedge clk); #1;
        rst = 0;

        // --- Verify recovery after reset ---
        repeat(3) @(posedge clk); #1;  // PC: 0 → 1 → 2 → 3

        $display("                                                            ");
        $display("  Simulation Complete.");
        $display("                                                            ");
        $finish;
    end

endmodule
