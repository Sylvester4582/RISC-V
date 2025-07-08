module pipeline_registers (
    input wire clk,
    input wire rst,
    
    // Stall and flush controls
    input wire stall_if_id,
    input wire flush_if_id,
    input wire stall_id_ex,
    input wire flush_id_ex,
    input wire stall_ex_mem,
    input wire flush_ex_mem,
    input wire stall_mem_wb,
    input wire flush_mem_wb,
    
    // IF/ID Pipeline Register
    input wire [63:0] if_pc,
    input wire [31:0] if_instruction,
    output reg [63:0] id_pc,
    output reg [31:0] id_instruction,
    
    // ID/EX Pipeline Register
    input wire [63:0] id_rs1_data,
    input wire [63:0] id_rs2_data,
    input wire [63:0] id_immediate,
    input wire [4:0] id_rs1_addr,
    input wire [4:0] id_rs2_addr,
    input wire [4:0] id_rd_addr,
    input wire [2:0] id_funct3,
    input wire [6:0] id_funct7,
    input wire id_mem_read,
    input wire id_mem_write,
    input wire id_reg_write,
    input wire id_alu_src_b_sel,
    
    output reg [63:0] ex_rs1_data,
    output reg [63:0] ex_rs2_data,
    output reg [63:0] ex_immediate,
    output reg [4:0] ex_rs1_addr,
    output reg [4:0] ex_rs2_addr,
    output reg [4:0] ex_rd_addr,
    output reg [2:0] ex_funct3,
    output reg [6:0] ex_funct7,
    output reg ex_mem_read,
    output reg ex_mem_write,
    output reg ex_reg_write,
    output reg ex_alu_src_b_sel,
    
    // EX/MEM Pipeline Register
    input wire [63:0] ex_alu_result,
    input wire [63:0] ex_rs2_data_fwd,
    output reg [63:0] mem_alu_result,
    output reg [63:0] mem_write_data,
    output reg [4:0] mem_rd_addr,
    output reg mem_mem_read,
    output reg mem_mem_write,
    output reg mem_reg_write,
    
    // MEM/WB Pipeline Register
    input wire [63:0] mem_read_data,
    input wire [63:0] mem_alu_result_in,
    output reg [63:0] wb_read_data,
    output reg [63:0] wb_alu_result,
    output reg [4:0] wb_rd_addr,
    output reg wb_reg_write,
    output reg wb_mem_read
);

    // IF/ID Pipeline Register
    always @(posedge clk) begin
        if (rst || flush_if_id) begin
            id_pc <= 64'b0;
            id_instruction <= 32'b0;
        end
        else if (!stall_if_id) begin
            id_pc <= if_pc;
            id_instruction <= if_instruction;
        end
    end

    // ID/EX Pipeline Register
    always @(posedge clk) begin
        if (rst || flush_id_ex) begin
            ex_rs1_data <= 64'b0;
            ex_rs2_data <= 64'b0;
            ex_immediate <= 64'b0;
            ex_rs1_addr <= 5'b0;
            ex_rs2_addr <= 5'b0;
            ex_rd_addr <= 5'b0;
            ex_funct3 <= 3'b0;
            ex_funct7 <= 7'b0;
            ex_mem_read <= 1'b0;
            ex_mem_write <= 1'b0;
            ex_reg_write <= 1'b0;
            ex_alu_src_b_sel <= 1'b0;
        end
        else if (!stall_id_ex) begin
            ex_rs1_data <= id_rs1_data;
            ex_rs2_data <= id_rs2_data;
            ex_immediate <= id_immediate;
            ex_rs1_addr <= id_rs1_addr;
            ex_rs2_addr <= id_rs2_addr;
            ex_rd_addr <= id_rd_addr;
            ex_funct3 <= id_funct3;
            ex_funct7 <= id_funct7;
            ex_mem_read <= id_mem_read;
            ex_mem_write <= id_mem_write;
            ex_reg_write <= id_reg_write;
            ex_alu_src_b_sel <= id_alu_src_b_sel;
        end
    end

    // EX/MEM Pipeline Register
    always @(posedge clk) begin
        if (rst || flush_ex_mem) begin
            mem_alu_result <= 64'b0;
            mem_write_data <= 64'b0;
            mem_rd_addr <= 5'b0;
            mem_mem_read <= 1'b0;
            mem_mem_write <= 1'b0;
            mem_reg_write <= 1'b0;
        end
        else if (!stall_ex_mem) begin
            mem_alu_result <= ex_alu_result;
            mem_write_data <= ex_rs2_data_fwd;
            mem_rd_addr <= ex_rd_addr;
            mem_mem_read <= ex_mem_read;
            mem_mem_write <= ex_mem_write;
            mem_reg_write <= ex_reg_write;
        end
    end

    // MEM/WB Pipeline Register
    always @(posedge clk) begin
        if (rst || flush_mem_wb) begin
            wb_read_data <= 64'b0;
            wb_alu_result <= 64'b0;
            wb_rd_addr <= 5'b0;
            wb_reg_write <= 1'b0;
            wb_mem_read <= 1'b0;
        end
        else if (!stall_mem_wb) begin
            wb_read_data <= mem_read_data;
            wb_alu_result <= mem_alu_result_in;
            wb_rd_addr <= mem_rd_addr;
            wb_reg_write <= mem_reg_write;
            wb_mem_read <= mem_mem_read;
        end
    end

endmodule