// Decode Stage - Processes instruction and generates control signals
// - Decodes instruction fields
// - Reads register file values
// - Generates immediate values
// - Produces control signals
// - Manages register writeback interface

module id_stage (
    input wire clk,
    input wire rst,
    input wire [31:0] instruction,
    input wire [63:0] wb_data,
    input wire wb_reg_write,
    input wire [4:0] wb_rd_addr,
    output wire [63:0] rs1_data,
    output wire [63:0] rs2_data,
    output wire [63:0] immediate,
    output wire [4:0] rd_addr,
    output wire mem_read,
    output wire mem_write,
    output wire reg_write,
    output wire branch,
    output wire [2:0] alu_funct3,
    output wire [6:0] alu_funct7,
    output wire alu_src_b_sel
);
    wire [2:0] imm_type;

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
        .imm_type(imm_type),
        .alu_src_b_sel(alu_src_b_sel)
    );
    
    // Register file
    register_file regfile (
        .clk(clk),
        .rst(rst),
        .rs1_addr(instruction[19:15]),
        .rs2_addr(instruction[24:20]),
        .rd_addr(wb_rd_addr),
        .rd_data(wb_data),
        .reg_write(wb_reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );
    
    // Immediate generator
    immediate_generator imm_gen (
        .instruction(instruction),
        .imm_type(imm_type),
        .immediate(immediate)
    );

    assign rd_addr = instruction[11:7];

endmodule 