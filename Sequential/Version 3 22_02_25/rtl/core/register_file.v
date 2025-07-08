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
            
        // Initialize test values for basic operations
        registers[1] = 64'd1;   // x1 = 1
        registers[2] = 64'd2;   // x2 = 2
        registers[3] = 64'd3;   // x3 = 3
        registers[4] = 64'd4;   // x4 = 4
        registers[5] = 64'd5;   // x5 = 5
        
        // Debug output
        $display("Initial register values:");
        for (i = 0; i < 6; i = i + 1)
            $display("x%0d = %0d", i, registers[i]);
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
            registers[1] <= 64'd1;
            registers[2] <= 64'd2;
            registers[3] <= 64'd3;
            registers[4] <= 64'd4;
            registers[5] <= 64'd5;
        end
        else if (reg_write && rd_addr != 5'b0) begin  // Don't write to x0
            registers[rd_addr] <= rd_data;
            $display("Register Write: x%0d = %h", rd_addr, rd_data);
        end
    end
endmodule