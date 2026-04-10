module alu(
    input  wire  [3:0]  opcode,
    input  wire  [7:0]  acc_in,
    input  wire  [7:0]  operand,
    output reg   [7:0]  acc_out,
    output reg   [15:0] extended_out,
    output reg          c_b           // carry (ADD/SHL) | borrow (SUB) | LSB (SHR)
);

    always @(*) begin
        // Safe defaults — avoid latches
        acc_out      = acc_in;
        extended_out = 16'd0;
        c_b          = 1'b0;

        case (opcode)
            // --- Arithmetic ---
            4'b0001: {c_b, acc_out} = {1'b0, acc_in} + {1'b0, operand};  // ADD  — carry out
            4'b0010: {c_b, acc_out} = {1'b0, acc_in} - {1'b0, operand};  // SUB  — borrow out
            4'b0011: extended_out   = acc_in * operand;                   // MUL  — 16-bit result

            // --- Logical ---
            4'b0100: acc_out = acc_in | operand;   // OR
            4'b0101: acc_out = acc_in & operand;   // AND
            4'b0110: acc_out = acc_in ^ operand;   // XOR
            4'b0111: c_b     = (acc_in < operand); // CMP — sets c_b if acc < operand

            // --- Shift ---
            4'b1000: {c_b, acc_out} = {acc_in, 1'b0};          // SHL — MSB → c_b
            4'b1001: {acc_out, c_b} = {1'b0, acc_in};          // SHR — LSB → c_b

            default: begin
                acc_out      = acc_in;
                extended_out = 16'd0;
                c_b          = 1'b0;
            end
        endcase
    end

endmodule
