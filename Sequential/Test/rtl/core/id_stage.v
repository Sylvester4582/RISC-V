module id_stage (
    input wire clk,
    input wire rst,
    input wire [31:0] instruction,
    input wire [63:0] rd_data,
    input wire reg_write,
    output wire [63:0] rs1_data,
    output wire [63:0] rs2_data,
    output wire [63:0] immediate,
    output wire mem_read,
    output wire mem_write,
    output wire branch,
    output wire [2:0] alu_funct3,
    output wire [6:0] alu_funct7,
    output wire is_immediate,
    output wire alu_src_b_sel
);

    // Control unit
    control_unit ctrl (
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .branch(branch),
        .alu_funct3(alu_funct3),
        .alu_funct7(alu_funct7),
        .is_immediate(is_immediate),
        .imm_type(imm_type),
        .alu_src_b_sel(alu_src_b_sel)
    );
    
    // Register file
    register_file regfile (
        .clk(clk),
        .rst(rst),
        .rs1_addr(instruction[19:15]),
        .rs2_addr(instruction[24:20]),
        .rd_addr(instruction[11:7]),
        .rd_data(rd_data),
        .reg_write(reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );
    
    // Immediate generator
    wire [2:0] imm_type;
    immediate_generator imm_gen (
        .instruction(instruction),
        .imm_type(imm_type),
        .immediate(immediate)
    );

endmodule 