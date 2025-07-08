// Data Memory - Implements main memory for data storage
// - Provides 1024 64-bit word storage
// - Supports read and write operations
// - Handles 8-byte aligned access

module data_memory(
    input wire clk,
    input wire mem_read,
    input wire mem_write,
    input wire [63:0] address,
    input wire [63:0] write_data,
    output reg [63:0] read_data
);
    // 1024 64-bit words
    reg [63:0] memory [0:1023];

    integer i;
    initial begin
        // Initialize memory
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 64'h0;
        end
        
        // Initialize some test data
        memory[0] = 64'd10;
        memory[1] = 64'd20;
        memory[2] = 64'd30;
    end
    
    // Synchronous write
    always @(posedge clk) begin
        if (mem_write) begin
            memory[address[11:3]] <= write_data;
            $display("Memory Write: Address=%h Data=%h", address, write_data);
        end
    end
    
    // Asynchronous read
    always @(*) begin
        if (mem_read)
            read_data = memory[address[11:3]];
        else
            read_data = 64'h0;
    end

endmodule