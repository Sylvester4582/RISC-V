// Register File - Implements RISC-V integer register bank
// - Contains 32 64-bit general-purpose registers
// - Supports dual read ports for rs1/rs2
// - Handles register write-back
// - Maintains x0 as hardwired zero
// - Includes reset and initialization logic

module register_file (
    input wire clk,
    input wire rst,
    input wire [4:0] rs1_addr,
    input wire [4:0] rs2_addr,
    input wire [4:0] rd_addr,
    input wire [63:0] rd_data,
    input wire reg_write,
    output reg [63:0] rs1_data,
    output reg [63:0] rs2_data
);
    reg [63:0] registers [0:31];  // 32 64-bit registers
    integer i;
    
    // Initialize registers
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 64'h0000000000000000;
            
        // Initialize test values
        registers[2] = 64'd2;   // x2 for ADD test
        registers[3] = 64'd3;   // x3 for ADD test
        registers[5] = 64'd5;   // x5 for SUB test
        registers[6] = 64'd4;   // x6 for SUB test
        registers[8] = 64'd0;   // x8 for ADDI test
        registers[9] = 64'd5;   // x9 for BEQ test
        registers[10] = 64'd4;  // x10 for BEQ test
        registers[15] = 64'd15; // x15 for SD (data to store)
        registers[16] = 64'd2;  // x16 for SD (base address)
        
        $display("\n=== Initial Register Values ===");
        $display("x9 (branch compare 1) = %0d", registers[9]);
        $display("x10 (branch compare 2) = %0d", registers[10]);
        $display("x15 (store data) = %0d", registers[15]);
        $display("x16 (base addr) = %0d", registers[16]);
    end
    
    // Read operation (combinational)
    always @(*) begin
        // x0 is hardwired to 0
        if (rs1_addr == 5'b00000)
            rs1_data = 64'h0;
        else
            rs1_data = registers[rs1_addr];
            
        if (rs2_addr == 5'b00000)
            rs2_data = 64'h0;
        else
            rs2_data = registers[rs2_addr];
    end
    
    // Write operation (sequential)
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 64'h0;
                
            // Reset to initial test values
            registers[2] <= 64'd2;
            registers[3] <= 64'd3;
            registers[5] <= 64'd5;
            registers[6] <= 64'd4;
            registers[8] <= 64'd0;   // For ADDI: x7 = x8 + 5
            registers[15] <= 64'd15;  // x15 for SD test
            registers[16] <= 64'd8;   // x16 for SD test
        end
        else if (reg_write && rd_addr != 5'b0) begin  // Don't write to x0
            registers[rd_addr] <= rd_data;
            $display("Register Write: x%0d = %h", rd_addr, rd_data);
        end
    end
endmodule