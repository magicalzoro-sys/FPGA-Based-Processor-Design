module processor (
    input  wire       clk,
    input  wire       en,
    output wire       C_B,
    output wire [7:0] accum_wire
);

    // ---- Internal state ----
    reg [7:0] accumulator;
    reg [7:0] extended_reg;
    reg [3:0] program_counter;
    reg       c_b;
    reg [7:0] registers [0:15];

    // ---- Instruction fetch (combinational) ----
    wire [7:0] instruction_code;
    wire [3:0] opcode;
    wire [3:0] reg_add;

    assign instruction_code = registers[program_counter];
    assign opcode            = instruction_code[7:4];
    assign reg_add           = instruction_code[3:0];

    // ---- Outputs ----
    assign accum_wire = accumulator;
    assign C_B        = c_b;

    // ---- Processor FSM ----
    // negedge en → initialise registers & reset state
    // posedge clk & en=1 → execute instruction at PC
    always @(posedge clk or negedge en) begin
        if (!en) begin
            // ----- Program + data memory initialisation -----
            // Instructions (PC 0–7)
            registers[0]  <= 8'b0000_0000;   // NOP
            registers[1]  <= 8'b0001_1111;   // ADD  R15
            registers[2]  <= 8'b0001_1110;   // ADD  R14
            registers[3]  <= 8'b0100_1101;   // (reserved opcode — acts as NOP)
            registers[4]  <= 8'b1010_1100;   // MOV  R12, ACC
            registers[5]  <= 8'b0011_1110;   // MUL  R14
            registers[6]  <= 8'b0000_0011;   // CIR  ACC
            registers[7]  <= 8'b1111_1111;   // HLT
            // Data registers (R8–R12 = scratch)
            registers[8]  <= 8'd0;
            registers[9]  <= 8'd0;
            registers[10] <= 8'd0;
            registers[11] <= 8'd0;
            registers[12] <= 8'd0;
            // Constant data
            registers[13] <= 8'd12;
            registers[14] <= 8'd24;
            registers[15] <= 8'd21;
            // Control state reset
            program_counter <= 4'd0;
            extended_reg    <= 8'd0;
            accumulator     <= 8'd0;
            c_b             <= 1'b0;

        end else begin
            // ----- Instruction execute -----
            case (opcode)

                4'b0001: begin // ADD Ri — 9-bit result, carry out
                    {c_b, accumulator} <= {1'b0, accumulator} + {1'b0, registers[reg_add]};
                    program_counter    <= program_counter + 4'd1;
                end

                4'b0010: begin // SUB Ri — 9-bit result, borrow out
                    {c_b, accumulator} <= {1'b0, accumulator} - {1'b0, registers[reg_add]};
                    program_counter    <= program_counter + 4'd1;
                end

                4'b0011: begin // MUL Ri — 16-bit result
                    {extended_reg, accumulator} <= accumulator * registers[reg_add];
                    program_counter             <= program_counter + 4'd1;
                end

                4'b0100: begin // Reserved — NOP
                    program_counter <= program_counter + 4'd1;
                end

                4'b0101: begin // AND Ri
                    accumulator     <= accumulator & registers[reg_add];
                    program_counter <= program_counter + 4'd1;
                end

                4'b0110: begin // XOR Ri
                    accumulator     <= accumulator ^ registers[reg_add];
                    program_counter <= program_counter + 4'd1;
                end

                4'b0111: begin // CMP Ri
                    c_b             <= (accumulator < registers[reg_add]);
                    program_counter <= program_counter + 4'd1;
                end

                4'b1000: begin // BR addr — conditional branch on C/B
                    if (c_b)
                        program_counter <= reg_add;
                    else
                        program_counter <= program_counter + 4'd1;
                end

                4'b1001: begin // MOV ACC, Ri
                    accumulator     <= registers[reg_add];
                    program_counter <= program_counter + 4'd1;
                end

                4'b1010: begin // MOV Ri, ACC
                    registers[reg_add] <= accumulator;
                    program_counter    <= program_counter + 4'd1;
                end

                4'b1011: begin // RET addr — return to addr+1
                    program_counter <= reg_add + 4'd1;
                end

                4'b0000: begin // Misc operations
                    case (reg_add)
                        4'b0000: accumulator <= accumulator;                              // NOP
                        4'b0001: {c_b, accumulator} <= {accumulator, 1'b0};              // LSL ACC — MSB→c_b
                        4'b0010: {accumulator, c_b} <= {1'b0, accumulator};              // LSR ACC — LSB→c_b
                        4'b0011: accumulator <= {accumulator[0],   accumulator[7:1]};    // CIR ACC
                        4'b0100: accumulator <= {accumulator[6:0], accumulator[7]};      // CIL ACC
                        4'b0101: accumulator <= $signed(accumulator) >>> 1;              // ASR ACC
                        4'b0110: {c_b, accumulator} <= {1'b0, accumulator} + 9'd1;       // INC ACC
                        4'b0111: {c_b, accumulator} <= {1'b0, accumulator} - 9'd1;       // DEC ACC
                        default: accumulator <= accumulator;
                    endcase
                    program_counter <= program_counter + 4'd1;
                end

                4'b1111: begin // HLT — freeze PC
                    // PC intentionally not updated; processor halts
                end

                default: begin
                    program_counter <= program_counter + 4'd1;
                end

            endcase
        end
    end

endmodule
