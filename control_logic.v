module control_logic(
    input  wire       clk,
    input  wire       rst,
    input  wire       branch,
    input  wire [3:0] branch_addr,
    output reg  [3:0] pc
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 4'd0;               // async reset
        else if (branch)
            pc <= branch_addr;        // branch taken
        else
            pc <= pc + 4'd1;          // sequential increment
    end

endmodule
