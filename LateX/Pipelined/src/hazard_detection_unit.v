module hazard_detection_unit (
    // Pipeline register addresses
    input wire [4:0] id_rs1_addr,
    input wire [4:0] id_rs2_addr,
    input wire [4:0] ex_rd_addr,
    input wire [4:0] mem_rd_addr,
    
    // Control signals
    input wire ex_mem_read,
    input wire id_branch,
    input wire branch_taken,
    
    // Hazard control outputs
    output reg stall_if,
    output reg stall_id,
    output reg flush_ex
);

    always @(*) begin
        // Default values
        stall_if = 1'b0;
        stall_id = 1'b0;
        flush_ex = 1'b0;
        
        // Load-use hazard detection
        if (ex_mem_read && 
            ((ex_rd_addr == id_rs1_addr) || (ex_rd_addr == id_rs2_addr)) &&
            (ex_rd_addr != 5'b0)) begin
            stall_if = 1'b1;
            stall_id = 1'b1;
        end
        
        // Branch hazard detection
        if (id_branch && ex_rd_addr != 5'b0 &&
            ((ex_rd_addr == id_rs1_addr) || (ex_rd_addr == id_rs2_addr))) begin
            // Stall for one cycle if branch depends on result of previous instruction
            stall_if = 1'b1;
            stall_id = 1'b1;
            flush_ex = 1'b1;
        end
        
        // Branch taken flush
        if (branch_taken) begin
            flush_ex = 1'b1;
        end
    end

endmodule
