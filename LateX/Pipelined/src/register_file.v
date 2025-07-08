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
    
    // Initialize registers to 0
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 64'h0000000000000000;

    end
    
    // Read
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
    
    // Write
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 64'h0;
                
            // Re-initialize specific registers after reset
            registers[1] <= 64'd5;  // x1 = 5
            registers[2] <= 64'd6;  // x2 = 6
            registers[3] <= 64'd9;  // x3 = 9
            registers[4] <= 64'd8;  // x4 = 8
        end
        else if (reg_write && rd_addr != 5'b0) begin  // Don't write to x0
            registers[rd_addr] <= rd_data;
            $display("Register Write: x%0d = %h", rd_addr, rd_data);
        end
    end
endmodule