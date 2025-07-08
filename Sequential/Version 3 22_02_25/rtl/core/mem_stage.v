// Memory Stage - Handles all memory access operations
// - Interfaces with data memory for loads/stores
// - Uses ALU result as memory address
// - Processes store data from rs2
// - Manages memory read/write control
// - Provides read data for writeback

module mem_stage (
    input wire clk,
    input wire [63:0] alu_result,
    input wire [63:0] rs2_data,
    input wire mem_read,
    input wire mem_write,
    output wire [63:0] read_data
);
    // Data memory
    data_memory dmem (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),  // Address from ALU (base + offset)
        .write_data(rs2_data), // Data to write for SD
        .read_data(read_data)  // Data read for LD
    );

    // Debug output
    always @(posedge clk) begin
        if (mem_write)
            $display("MEM: Store %h to address %h", rs2_data, alu_result);
        if (mem_read)
            $display("MEM: Load %h from address %h", read_data, alu_result);
    end

endmodule