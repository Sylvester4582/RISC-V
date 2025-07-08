// Core - Sequential single-cycle RISC-V processor implementation
// - Executes one instruction per clock cycle
// - Combines fetch, decode, execute, memory, and writeback operations
// - Manages instruction flow and execution
// - Controls memory and register file access

module main(
    input wire clk,
    input wire rst
);
    // Pipeline stage signals
    wire [63:0] if_pc;
    wire [31:0] if_instruction;
    
    // Hazard control signals
    wire stall_if, stall_id, flush_ex;
    wire [1:0] forward_a, forward_b;
    
    // IF stage signals
    reg [63:0] pc_reg;
    wire [63:0] next_pc;
    wire [63:0] branch_target;
    wire branch_taken;
    
    // ID stage signals
    wire [63:0] id_pc;
    wire [31:0] id_instruction;
    wire [63:0] id_rs1_data, id_rs2_data, id_immediate;
    wire id_mem_read, id_mem_write, id_reg_write, id_alu_src_b_sel;
    wire [2:0] id_alu_funct3;
    wire [6:0] id_alu_funct7;
    wire [2:0] id_imm_type;
    wire id_branch;
    
    // EX stage signals
    reg [63:0] ex_rs1_data_fwd_reg, ex_rs2_data_fwd_reg;
    wire [63:0] ex_rs1_data_fwd, ex_rs2_data_fwd;
    wire [63:0] ex_alu_result;
    
    // MEM stage signals
    wire [63:0] mem_read_data;
    
    // WB stage signals
    wire [63:0] wb_data;
    
    // PC logic
    assign if_pc = pc_reg;
    assign next_pc = (branch_taken) ? branch_target : (pc_reg + 4);
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_reg <= 64'h0;
        end else if (!stall_if) begin
            pc_reg <= next_pc;
        end
    end
    
    // Instruction memory
    instruction_memory imem (
        .pc(if_pc),
        .instruction(if_instruction)
    );
    
    // Pipeline registers
    pipeline_registers pipe_regs (
        .clk(clk),
        .rst(rst),
        
        // Stall and flush controls
        .stall_if_id(stall_if),
        .flush_if_id(branch_taken),
        .stall_id_ex(stall_id),
        .flush_id_ex(flush_ex),
        .stall_ex_mem(1'b0),
        .flush_ex_mem(1'b0),
        .stall_mem_wb(1'b0),
        .flush_mem_wb(1'b0),
        
        // IF/ID
        .if_pc(if_pc),
        .if_instruction(if_instruction),
        .id_pc(id_pc),
        .id_instruction(id_instruction),
        
        // ID/EX
        .id_rs1_data(id_rs1_data),
        .id_rs2_data(id_rs2_data),
        .id_immediate(id_immediate),
        .id_rs1_addr(id_instruction[19:15]),
        .id_rs2_addr(id_instruction[24:20]),
        .id_rd_addr(id_instruction[11:7]),
        .id_funct3(id_alu_funct3),
        .id_funct7(id_alu_funct7),
        .id_mem_read(id_mem_read),
        .id_mem_write(id_mem_write),
        .id_reg_write(id_reg_write),
        .id_alu_src_b_sel(id_alu_src_b_sel),
        
        // EX/MEM
        .ex_alu_result(ex_alu_result),
        .ex_rs2_data_fwd(ex_rs2_data_fwd),
        
        // MEM/WB
        .mem_read_data(mem_read_data),
        .mem_alu_result_in(pipe_regs.mem_alu_result)
    );
    
    // Forward mux for ALU operands
    assign ex_rs1_data_fwd = 
        (forward_a == 2'b10) ? pipe_regs.mem_alu_result :  // Forward from MEM
        (forward_a == 2'b01) ? wb_data :                   // Forward from WB
        pipe_regs.ex_rs1_data;                            // No forwarding
        
    assign ex_rs2_data_fwd = 
        (forward_b == 2'b10) ? pipe_regs.mem_alu_result :  // Forward from MEM
        (forward_b == 2'b01) ? wb_data :                   // Forward from WB
        pipe_regs.ex_rs2_data;                            // No forwarding
    
    // Hazard detection unit
    hazard_detection_unit hazard_unit (
        .id_rs1_addr(id_instruction[19:15]),
        .id_rs2_addr(id_instruction[24:20]),
        .ex_rd_addr(pipe_regs.ex_rd_addr),
        .mem_rd_addr(pipe_regs.mem_rd_addr),
        .ex_mem_read(pipe_regs.ex_mem_read),
        .id_branch(id_branch),
        .branch_taken(branch_taken),
        .stall_if(stall_if),
        .stall_id(stall_id),
        .flush_ex(flush_ex)
    );
    
    // Forwarding unit
    forwarding_unit forward_unit (
        .ex_rs1_addr(pipe_regs.ex_rs1_addr),
        .ex_rs2_addr(pipe_regs.ex_rs2_addr),
        .mem_rd_addr(pipe_regs.mem_rd_addr),
        .wb_rd_addr(pipe_regs.wb_rd_addr),
        .mem_reg_write(pipe_regs.mem_reg_write),
        .wb_reg_write(pipe_regs.wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );
    
    // Control unit
    control_unit ctrl (
        .opcode(id_instruction[6:0]),
        .funct3(id_instruction[14:12]),
        .funct7(id_instruction[31:25]),
        .mem_read(id_mem_read),
        .mem_write(id_mem_write),
        .reg_write(id_reg_write),
        .branch(id_branch),
        .alu_funct3(id_alu_funct3),
        .alu_funct7(id_alu_funct7),
        .imm_type(id_imm_type),
        .alu_src_b_sel(id_alu_src_b_sel)
    );
    
    // Register file
    register_file regfile (
        .clk(clk),
        .rst(rst),
        .rs1_addr(id_instruction[19:15]),
        .rs2_addr(id_instruction[24:20]),
        .rd_addr(pipe_regs.wb_rd_addr),
        .rd_data(wb_data),
        .reg_write(pipe_regs.wb_reg_write),
        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data)
    );
    
    // Immediate generator
    immediate_generator imm_gen (
        .instruction(id_instruction),
        .imm_type(id_imm_type),
        .immediate(id_immediate)
    );
    
    // ALU
    alu alu_unit (
        .funct3(pipe_regs.ex_funct3),
        .funct7(pipe_regs.ex_funct7),
        .rs1(ex_rs1_data_fwd),
        .rs2(pipe_regs.ex_alu_src_b_sel ? pipe_regs.ex_immediate : ex_rs2_data_fwd),
        .rd(ex_alu_result)
    );
    
    // Branch unit
    branch_unit br_unit (
        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data),
        .branch(id_branch),
        .funct3(id_alu_funct3),
        .pc(id_pc),
        .imm(id_immediate),
        .take_branch(branch_taken),
        .branch_target(branch_target)
    );
    
    // Data memory
    data_memory dmem (
        .clk(clk),
        .mem_read(pipe_regs.mem_mem_read),
        .mem_write(pipe_regs.mem_mem_write),
        .address(pipe_regs.mem_alu_result),
        .write_data(pipe_regs.mem_write_data),
        .read_data(mem_read_data)
    );
    
    // Write-back mux
    assign wb_data = pipe_regs.wb_mem_read ? pipe_regs.wb_read_data : pipe_regs.wb_alu_result;

endmodule