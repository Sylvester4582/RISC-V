// Control Unit - Decodes instructions and generates control signals
// - Decodes RISC-V instruction opcode and function codes
// - Generates memory control signals (read/write)
// - Controls register file writes
// - Manages branch operations
// - Sets ALU operation type
// - Controls immediate value handling
// - Determines ALU input sources

module control_unit(
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    
    // Memory control
    output reg mem_read,
    output reg mem_write,
    
    // Register control
    output reg reg_write,
    
    // Branch control
    output reg branch,
    
    // ALU control
    output reg [2:0] alu_funct3,
    output reg [6:0] alu_funct7,
    
    // Immediate control
    output reg [2:0] imm_type,
    
    // ALU input selection
    output reg alu_src_b_sel
);
    // Required RISC-V Opcodes
    localparam R_TYPE    = 7'b0110011; // ADD, SUB
    localparam I_TYPE    = 7'b0010011; // ADDI
    localparam I_TYPE_LD = 7'b0000011; // LD
    localparam S_TYPE    = 7'b0100011; // SD
    localparam B_TYPE    = 7'b1100011; // BEQ

    // Immediate Types
    localparam IMM_I = 3'b000;
    localparam IMM_S = 3'b001;
    localparam IMM_B = 3'b010;

    always @(*) begin
        // Default values
        mem_read = 0;
        mem_write = 0;
        reg_write = 0;
        branch = 0;
        alu_funct3 = 3'b000;
        alu_funct7 = 7'b0000000;
        imm_type = IMM_I;
        alu_src_b_sel = 0;

        case (opcode)
            R_TYPE: begin // ADD, SUB
                reg_write = 1;
                alu_funct3 = funct3;
                alu_funct7 = funct7;
            end

            I_TYPE: begin // ADDI
                reg_write = 1;
                alu_src_b_sel = 1;
                alu_funct3 = funct3;
            end

            I_TYPE_LD: begin // LD
                mem_read = 1;
                reg_write = 1;
                alu_src_b_sel = 1;
            end

            S_TYPE: begin // SD
                mem_write = 1;
                alu_src_b_sel = 1;
                imm_type = IMM_S;
            end

            B_TYPE: begin // BEQ, BNE
                branch = 1;
                imm_type = IMM_B;
                alu_funct3 = funct3;
            end
        endcase
    end

endmodule