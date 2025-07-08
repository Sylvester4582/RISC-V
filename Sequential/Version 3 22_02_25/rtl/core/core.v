// Core - Top level 5-stage RISC-V processor implementation
// - Implements fetch, decode, execute, memory, and writeback stages
// - Manages stage transitions
// - Coordinates data and control signal flow between stages
// - Handles branch resolution and PC updates
// - Controls memory and register file access

module core(
    input wire clk,
    input wire rst
);
    // Stage interconnect signals
    wire [63:0] pc;
    wire [31:0] instruction;
    wire [63:0] rs1_data, rs2_data, immediate;
    wire [4:0] rd_addr;
    wire [63:0] alu_result, mem_read_data, wb_data;
    
    // Control signals
    wire mem_read, mem_write, reg_write, branch;
    wire [2:0] alu_funct3;
    wire [6:0] alu_funct7;
    wire alu_src_b_sel;
    
    // Branch signals
    wire branch_taken;
    wire [63:0] branch_target;
    
    // Pipeline control
    reg [2:0] state;
    localparam FETCH    = 3'b000;
    localparam DECODE   = 3'b001;
    localparam EXECUTE  = 3'b010;
    localparam MEMORY   = 3'b011;
    localparam WRITEBACK = 3'b100;
    
    // Stage enable signals
    reg [4:0] stage_enable;
    wire fetch_enable    = stage_enable[0];
    wire decode_enable   = stage_enable[1];
    wire execute_enable  = stage_enable[2];
    wire memory_enable   = stage_enable[3];
    wire writeback_enable = stage_enable[4];

    // State machine and pipeline control
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= FETCH;
            stage_enable <= 5'b00001;  // Enable only fetch stage
        end else begin
            stage_enable <= 5'b00000;  // Default: disable all stages
            
            case (state)
                FETCH: begin
                    if (instruction != 32'h00000013) begin  // Not NOP
                        state <= DECODE;
                        stage_enable <= 5'b00010;  // Enable decode
                        $display("FETCH: PC=%h Inst=%h", pc, instruction);
                    end else begin
                        state <= FETCH;
                        stage_enable <= 5'b00001;  // Stay in fetch
                        $display("FETCH: NOP detected");
                    end
                end
                
                DECODE: begin
                    state <= EXECUTE;
                    stage_enable <= 5'b00100;
                    $display("DECODE: op=%h rs1=%h rs2=%h rd=%h imm=%h",
                            instruction[6:0], rs1_data, rs2_data, rd_addr, immediate);
                end
                
                EXECUTE: begin
                    if (branch && branch_taken) begin
                        state <= FETCH;
                        stage_enable <= 5'b00001;
                        $display("EXECUTE: Branch taken to %h", branch_target);
                    end else begin
                        state <= MEMORY;
                        stage_enable <= 5'b01000;
                        $display("EXECUTE: ALU=%h", alu_result);
                    end
                end
                
                MEMORY: begin
                    state <= WRITEBACK;
                    stage_enable <= 5'b10000;
                    if (mem_read)
                        $display("MEMORY: Load %h from %h", mem_read_data, alu_result);
                    else if (mem_write)
                        $display("MEMORY: Store %h to %h", rs2_data, alu_result);
                end
                
                WRITEBACK: begin
                    state <= FETCH;
                    stage_enable <= 5'b00001;
                    if (reg_write)
                        $display("WRITEBACK: x%0d = %h", rd_addr, wb_data);
                end
            endcase
        end
    end

    // Pipeline stages
    if_stage if_stage_inst (
        .clk(clk && fetch_enable),
        .rst(rst),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .pc(pc),
        .instruction(instruction)
    );
    
    id_stage id_stage_inst (
        .clk(clk && decode_enable),
        .rst(rst),
        .instruction(instruction),
        .wb_data(wb_data),
        .wb_reg_write(writeback_enable),
        .wb_rd_addr(rd_addr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .immediate(immediate),
        .rd_addr(rd_addr),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .branch(branch),
        .alu_funct3(alu_funct3),
        .alu_funct7(alu_funct7),
        .alu_src_b_sel(alu_src_b_sel)
    );
    
    ex_stage ex_stage_inst (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .immediate(immediate),
        .alu_funct3(alu_funct3),
        .alu_funct7(alu_funct7),
        .alu_src_b_sel(alu_src_b_sel),
        .branch(branch),
        .pc(pc),
        .alu_result(alu_result),
        .branch_taken(branch_taken),
        .branch_target(branch_target)
    );
    
    mem_stage mem_stage_inst (
        .clk(clk && memory_enable),
        .alu_result(alu_result),
        .rs2_data(rs2_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .read_data(mem_read_data)
    );
    
    wb_stage wb_stage_inst (
        .mem_read_data(mem_read_data),
        .alu_result(alu_result),
        .mem_read(mem_read),
        .wb_data(wb_data)
    );

endmodule