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
    output reg is_immediate,
    
    // Immediate control
    output reg [2:0] imm_type,
    
    // ALU input selection
    output reg alu_src_b_sel
);
    // Required RISC-V Opcodes
    localparam R_TYPE     = 7'b0110011;  // Register-Register (add, sub, and, or)
    localparam I_TYPE_LD  = 7'b0000011;  // Load (ld)
    localparam S_TYPE     = 7'b0100011;  // Store (sd)
    localparam B_TYPE     = 7'b1100011;  // Branch (beq)
    localparam I_TYPE_ALU = 7'b0010011;  // I-type ALU operations

    // Immediate type encodings
    localparam IMM_I = 3'b000;
    localparam IMM_S = 3'b001;
    localparam IMM_B = 3'b010;

// ** Gp above

    always @(*) begin
       
        mem_read = 0;
        mem_write = 0;
        reg_write = 0;
        branch = 0;
        alu_funct3 = funct3;
        alu_funct7 = funct7;
        is_immediate = 0;
        imm_type = IMM_I;
        alu_src_b_sel = 0;

        case (opcode)
            R_TYPE: begin
                reg_write = 1;
            end

            I_TYPE_ALU: begin
                reg_write = 1;
                is_immediate = 1;
                imm_type = IMM_I;
                alu_src_b_sel = 1;
                alu_funct7 = 7'b0000000;
            end

            I_TYPE_LD: begin
                mem_read = 1;
                reg_write = 1;
                is_immediate = 1;
                imm_type = IMM_I;
                alu_src_b_sel = 1;
                alu_funct3 = 3'b000;
                alu_funct7 = 7'b0000000;
            end

            S_TYPE: begin
                mem_write = 1;
                is_immediate = 1;
                imm_type = IMM_S;
                alu_src_b_sel = 1;
                alu_funct3 = 3'b000;
                alu_funct7 = 7'b0000000;
            end

            B_TYPE: begin
                if (funct3 == 3'b000) begin
                    branch = 1;
                    imm_type = IMM_B;
                    alu_funct3 = 3'b000;
                    alu_funct7 = 7'b0100000;
                end
            end
        endcase
    end

endmodule