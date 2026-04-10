module accumulator_module(
    input  wire       clk,
    input  wire       rst,
    input  wire       load,
    input  wire [7:0] acc_in,
    output reg  [7:0] acc_out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            acc_out <= 8'd0;       // async reset
        else if (load)
            acc_out <= acc_in;     // synchronous load
        // else: hold — implicit, no latch since it's a register
    end

endmodule
