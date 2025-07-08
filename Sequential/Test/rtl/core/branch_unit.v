module branch_unit (
    input wire [63:0] rs1_data,        // First source register
    input wire [63:0] rs2_data,        // Second source register
    input wire [2:0] funct3,           // Branch type from instruction
    input wire branch,                 // Branch instruction signal from control
    input wire [63:0] pc,             // Current PC
    input wire [63:0] imm,            // Branch immediate
    output reg take_branch,           // Branch decision
    output wire [63:0] branch_target  // Branch target address
);

    // Branch target
    assign branch_target = pc + imm;

    always @(*) begin
        if (!branch) begin
            take_branch = 1'b0;
        end else begin
            case (funct3)
                3'b000: take_branch = (rs1_data == rs2_data);  // BEQ
                3'b001: take_branch = (rs1_data != rs2_data);  // BNE
                3'b100: take_branch = ($signed(rs1_data) < $signed(rs2_data));  // BLT
                3'b101: take_branch = ($signed(rs1_data) >= $signed(rs2_data)); // BGE
                3'b110: take_branch = (rs1_data < rs2_data);  // BLTU
                3'b111: take_branch = (rs1_data >= rs2_data); // BGEU
                default: take_branch = 1'b0;
            endcase
        end
    end

endmodule 