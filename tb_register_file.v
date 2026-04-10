`timescale 1ns/1ns
`include "register_file.v"

module tb_register_file;

    reg        clk;
    reg        we;
    reg  [3:0] addr;
    reg  [7:0] data_in;
    wire [7:0] data_out;

    register_file uut (
        .clk      (clk),
        .we       (we),
        .addr     (addr),
        .data_in  (data_in),
        .data_out (data_out)
    );

        initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

        initial begin
        $dumpfile("register_file.vcd");
        $dumpvars(0, tb_register_file);
    end

    initial begin
        we      = 1'b0;
        addr    = 4'hx;
        data_in = 8'hxx;
        $display("  Time\t |  WE  |  Addr  |  Data_In   |  Data_Out");
        $monitor("  %4t  |   %b  |  %h    |  %b   |  %b  ",
                  $time, we, addr, data_in, data_out);
    end

    initial begin
        we = 0; addr = 4'h0; data_in = 8'h00;
        @(posedge clk); #1;   // sync to clock edge

        we = 1;
        addr = 4'd0;  data_in = 8'd10;  @(posedge clk); #1;
        addr = 4'd1;  data_in = 8'd25;  @(posedge clk); #1;
        addr = 4'd2;  data_in = 8'd50;  @(posedge clk); #1;
        addr = 4'd3;  data_in = 8'd45;  @(posedge clk); #1;
        addr = 4'd5;  data_in = 8'hAB;  @(posedge clk); #1;
        addr = 4'd15; data_in = 8'hFF;  @(posedge clk); #1;

        we = 0;
        addr = 4'd0;  @(posedge clk); #1;
        addr = 4'd1;  @(posedge clk); #1;
        addr = 4'd2;  @(posedge clk); #1;
        addr = 4'd3;  @(posedge clk); #1;
        addr = 4'd5;  @(posedge clk); #1;
        addr = 4'd15; @(posedge clk); #1;

        we = 1;
        addr = 4'd3; data_in = 8'hCC; @(posedge clk); #1;
        we = 0;
        addr = 4'd3; @(posedge clk); #1;  // read back new value

        we = 0;
        addr = 4'd1; data_in = 8'hFF; @(posedge clk); #1;
        addr = 4'd1; @(posedge clk); #1;  // must still read 25

        $display("                                                            ");
        $display("  Simulation Complete.");
        $display("                                                            ");
        $finish;
    end

endmodule
