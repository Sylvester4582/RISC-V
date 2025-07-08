// Data Memory - Implements main memory for data storage
// - Provides 1024 64-bit word storage
// - Supports read and write operations
// - Handles 8-byte aligned access
// - Includes test data initialization
// - Provides debug access functions

module data_memory(
    input wire clk,
    input wire mem_read,
    input wire mem_write,
    input wire [63:0] address,
    input wire [63:0] write_data,
    output reg [63:0] read_data
);
    reg [63:0] memory [0:1023];  // 1024 64-bit words
    
    integer i;
    initial begin
        // Initialize all memory locations to 0
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 64'h0000000000000000;
        end
        
        // Initialize some test data
        memory[0] = 64'd10;
        memory[1] = 64'd20;
        memory[2] = 64'd30;
        
        $display("Data memory initialized with test values:");
        $display("memory[0] = %0d (0x%h)", memory[0], memory[0]);
        $display("memory[1] = %0d (0x%h)", memory[1], memory[1]);
        $display("memory[2] = %0d (0x%h)", memory[2], memory[2]);
    end
    
    // Read operation (ld instruction)
    always @(*) begin
        if (mem_read) begin
            read_data = memory[address[10:3]];  // 8-byte aligned access
            $display("Memory Read: Address=0x%h Data=%0d (0x%h)", address, read_data, read_data);
        end else
            read_data = 64'b0;
    end
    
    // Write operation (sd instruction)
    always @(posedge clk) begin
        if (mem_write) begin
            memory[address[10:3]] <= write_data;
            $display("Memory Write: Address=0x%h Data=%0d (0x%h)", address, write_data, write_data);
        end
    end
    
    function [63:0] get_word;
        input [9:0] index;
        begin
            get_word = memory[index];
        end
    endfunction
endmodule