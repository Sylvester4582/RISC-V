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
        // Clear memory
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 64'h0000000000000000;
        end
    end
    
    // Read operation
    always @(*) begin
        if (mem_read)
            read_data = memory[address[10:3]];
        else
            read_data = 64'b0;
    end
    
    // Write operation
    always @(posedge clk) begin
        if (mem_write) begin
            memory[address[10:3]] <= write_data;
            // Debug
            $display("Memory Write: addr=%h data=%h", address[10:3], write_data);
        end
    end
    
    function [63:0] get_word;
        input [9:0] index;
        begin
            get_word = memory[index];
        end
    endfunction
endmodule