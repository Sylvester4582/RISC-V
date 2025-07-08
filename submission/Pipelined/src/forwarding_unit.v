module forwarding_unit (
    input wire [4:0] ex_rs1_addr,
    input wire [4:0] ex_rs2_addr,
    input wire [4:0] mem_rd_addr,
    input wire [4:0] wb_rd_addr,
    input wire mem_reg_write,
    input wire wb_reg_write,
    
    output reg [1:0] forward_a,  // RS1 forwarding control
    output reg [1:0] forward_b   // RS2 forwarding control
);

    always @(*) begin
        // Default: no forwarding
        forward_a = 2'b00;
        forward_b = 2'b00;
        
        // MEM hazard
        if (mem_reg_write && (mem_rd_addr != 0)) begin
            if (mem_rd_addr == ex_rs1_addr) begin
                forward_a = 2'b10;
            end
            if (mem_rd_addr == ex_rs2_addr) begin
                forward_b = 2'b10;
            end
        end
        
        // WB hazard
        if (wb_reg_write && (wb_rd_addr != 0)) begin
            if ((wb_rd_addr == ex_rs1_addr) && (mem_rd_addr != ex_rs1_addr)) begin
                forward_a = 2'b01;
            end
            if ((wb_rd_addr == ex_rs2_addr) && (mem_rd_addr != ex_rs2_addr)) begin
                forward_b = 2'b01;
            end
        end
    end

    // Consolidated forwarding debug output
    always @(*) begin
        if (forward_a != 2'b00 || forward_b != 2'b00) begin
            $display("[FORWARD] EX_RS1=%d, EX_RS2=%d, MEM_RD=%d, WB_RD=%d, FWD_A=%b, FWD_B=%b",
                ex_rs1_addr, ex_rs2_addr, mem_rd_addr, wb_rd_addr, forward_a, forward_b);
        end
    end

endmodule
