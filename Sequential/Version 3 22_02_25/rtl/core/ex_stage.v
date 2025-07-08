// Execute Stage - Performs arithmetic and branch operations
// - Contains ALU for data processing
// - Handles branch condition evaluation
// - Calculates branch target addresses
// - Selects between register and immediate operands
// - Generates results for memory/writeback

module ex_stage (
    input wire [63:0] rs1_data,
    input wire [63:0] rs2_data,
    input wire [63:0] immediate,
    input wire [2:0] alu_funct3,
    input wire [6:0] alu_funct7,
    input wire alu_src_b_sel,
    input wire branch,
    input wire [63:0] pc,
    output wire [63:0] alu_result,
    output wire branch_taken,
    output wire [63:0] branch_target
);
    // ALU
    alu alu_unit (
        .funct3(alu_funct3),
        .funct7(alu_funct7),
        .rs1(rs1_data),
        .rs2(alu_src_b_sel ? immediate : rs2_data),
        .rd(alu_result)
    );
    
    // Branch unit
    branch_unit br_unit (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .branch(branch),
        .funct3(alu_funct3),
        .pc(pc),
        .imm(immediate),
        .take_branch(branch_taken),
        .branch_target(branch_target)
    );

endmodule 