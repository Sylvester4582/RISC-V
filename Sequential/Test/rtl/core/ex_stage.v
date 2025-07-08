module ex_stage (
    input wire [63:0] rs1_data,
    input wire [63:0] rs2_data,
    input wire [63:0] immediate,
    input wire [2:0] alu_funct3,
    input wire [6:0] alu_funct7,
    input wire is_immediate,
    input wire alu_src_b_sel,
    input wire branch,
    input wire [63:0] pc,
    output wire [63:0] alu_result,
    output wire take_branch,
    output wire [63:0] branch_target
);

    // ALU
    alu alu_unit (
        .funct3(alu_funct3),
        .funct7(alu_funct7),
        .rs1(rs1_data),
        .rs2(alu_src_b_sel ? immediate : rs2_data),
        .is_immediate(is_immediate),
        .rd(alu_result)
    );
    
    // Branch unit
    branch_unit br_unit (
        .funct3(alu_funct3),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .branch(branch),
        .pc(pc),
        .imm(immediate),
        .take_branch(take_branch),
        .branch_target(branch_target)
    );

endmodule 