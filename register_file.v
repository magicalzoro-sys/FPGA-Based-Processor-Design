module register_file(
    input  wire        clk,
    input  wire        we,
    input  wire [3:0]  addr,
    input  wire [7:0]  data_in,
    output wire [7:0]  data_out
);

    reg [7:0] registers [0:15];   // 16 registers, 8-bit wide
    integer i;

    // Initialise all registers to 0
    initial begin
        for (i = 0; i < 16; i = i + 1)
            registers[i] = 8'h00;
    end

    // Synchronous write
    always @(posedge clk) begin
        if (we)
            registers[addr] <= data_in;
    end

    // Asynchronous read
    assign data_out = registers[addr];

endmodule
