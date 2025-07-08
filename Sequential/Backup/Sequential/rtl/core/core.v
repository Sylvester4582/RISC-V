// Core - Sequential single-cycle RISC-V processor implementation
// - Executes one instruction per clock cycle
// - Combines fetch, decode, execute, memory, and writeback operations
// - Manages instruction flow and execution
// - Controls memory and register file access

module core(
    input wire clk,
    input wire rst
);
    // Internal signals
    wire [63:0] pc;
    wire [31:0] instruction;
    wire [63:0] rs1_data, rs2_data, immediate;
    wire [63:0] alu_result, mem_read_data, wb_data;
    wire [4:0] rd_addr;
    
    // Control signals
    wire mem_read, mem_write, reg_write, branch;
    wire [2:0] alu_funct3;
    wire [6:0] alu_funct7;
    wire alu_src_b_sel;
    wire [2:0] imm_type;
    wire branch_taken;
    wire [63:0] branch_target;
    
    // Program counter logic
    reg [63:0] pc_reg;
    assign pc = pc_reg;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_reg <= 64'h0;
        end else begin
            pc_reg <= branch_taken ? branch_target : (pc_reg + 4);
        end
    end
    
    // Instruction memory
    instruction_memory imem (
        .pc(pc),
        .instruction(instruction)
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
        .rd_data(wb_data),
        .reg_write(reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );
    
    // Immediate generator
    immediate_generator imm_gen (
        .instruction(instruction),
        .imm_type(imm_type),
        .immediate(immediate)
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
    
    // Data memory
    data_memory dmem (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(rs2_data),
        .read_data(mem_read_data)
    );
    
    // Write-back multiplexer
    assign wb_data = mem_read ? mem_read_data : alu_result;

endmodule