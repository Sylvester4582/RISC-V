module core(
    input wire clk,
    input wire rst
);

    wire [63:0] pc;
    wire [31:0] instruction;
    wire [63:0] rs1_data, rs2_data;
    wire [63:0] immediate;
    wire [63:0] alu_result;
    wire [63:0] mem_read_data;
    wire take_branch;
    wire [63:0] branch_target;
    
    // Control
    wire mem_read, mem_write;
    wire reg_write;
    wire branch;
    wire [2:0] alu_funct3;
    wire [6:0] alu_funct7;
    wire is_immediate;
    wire alu_src_b_sel;
    
    // Instruction Fetch Stage
    if_stage if_stage_inst (
        .clk(clk),
        .rst(rst),
        .branch(branch && take_branch),
        .branch_target(branch_target),
        .pc(pc),
        .instruction(instruction)
    );
    
    // Instruction Decode Stage
    id_stage id_stage_inst (
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .rd_data(mem_read ? mem_read_data : alu_result),
        .reg_write(reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .immediate(immediate),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .alu_funct3(alu_funct3),
        .alu_funct7(alu_funct7),
        .is_immediate(is_immediate),
        .alu_src_b_sel(alu_src_b_sel)
    );
    
    // Execute Stage
    ex_stage ex_stage_inst (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .immediate(immediate),
        .alu_funct3(alu_funct3),
        .alu_funct7(alu_funct7),
        .is_immediate(is_immediate),
        .alu_src_b_sel(alu_src_b_sel),
        .branch(branch),
        .pc(pc),
        .alu_result(alu_result),
        .take_branch(take_branch),
        .branch_target(branch_target)
    );
    
    // Memory Stage
    mem_stage mem_stage_inst (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(rs2_data),
        .read_data(mem_read_data)
    );
    
    // Debug
    always @(posedge clk) begin
        if (!rst) begin
            $display("PC: %h", pc);
            $display("Instruction: %h", instruction);
            $display("Control: mem_read=%b mem_write=%b reg_write=%b branch=%b",
                    mem_read, mem_write, reg_write, branch);
            $display("ALU: rs1=%h rs2=%h result=%h",
                    rs1_data, rs2_data, alu_result);
            if (mem_read || mem_write)
                $display("Memory: addr=%h data=%h",
                        alu_result, mem_write ? rs2_data : mem_read_data);
            if (branch && take_branch)
                $display("Branch taken to %h", branch_target);
            $display("--------------------");
        end
    end

endmodule