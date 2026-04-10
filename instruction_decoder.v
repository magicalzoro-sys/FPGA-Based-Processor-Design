
module instruction_decoder(
    input  wire [7:0] instruction_code,
    output wire [3:0] opcode,
    output wire [3:0] reg_add
);
 
    // Upper nibble -> opcode | Lower nibble -> register address
    assign opcode  = instruction_code[7:4];
    assign reg_add = instruction_code[3:0];
 
endmodule