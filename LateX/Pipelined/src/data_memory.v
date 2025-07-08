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
        memory[0] = 64'd11;
        memory[1] = 64'd20;
        memory[2] = 64'd30;
        $display("Memory initialized: mem[0]=%d, mem[1]=%d, mem[2]=%d", memory[0], memory[1], memory[2]);
    end
    
    // Synchronous write
    always @(posedge clk) begin
        if (mem_write) begin
            memory[address[11:3]] <= write_data;
            $display("Memory Write: Address=%h Data=%h (Index=%d)", 
                    address, write_data, address[11:3]);
            $display("NOTE: To access memory[N], use address=N*8");
        end
    end
    
    // Asynchronous read
    always @(*) begin
        if (mem_read) begin
            read_data = memory[address[11:3]];
            $display("Memory Read: Address=%h (Index=%d) Data=%h", 
                    address, address[11:3], memory[address[11:3]]);
        end
        else
            read_data = 64'h0;
    end

endmodule