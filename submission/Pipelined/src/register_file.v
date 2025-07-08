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
    
    initial begin
        // Initialize all registers to 0 first
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 64'h0;
        end
        
        // Initialize test values
        registers[1] = 64'h5;
        registers[2] = 64'h6;
        registers[3] = 64'h9;
        registers[4] = 64'h8;
        registers[5] = 64'h1;
        
        $display("[INIT] Register file initialized with test values:");
        for (i = 1; i < 32; i = i + 1) begin
            if (registers[i] != 0)
                $display("    x%-2d = 0x%h", i, registers[i]);
        end
        $display("");
    end
    
    // Read
    always @(*) begin
        // x0 is hardwired to 0
        rs1_data = (rs1_addr == 0) ? 64'h0 : registers[rs1_addr];
        rs2_data = (rs2_addr == 0) ? 64'h0 : registers[rs2_addr];
    end
    
    // Write
    always @(posedge clk) begin
        if (reg_write && rd_addr != 0) begin
            registers[rd_addr] <= rd_data;
            $display("[REGISTER] Write: x%0d = 0x%h", rd_addr, rd_data);
        end
    end
endmodule