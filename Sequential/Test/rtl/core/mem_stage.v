module mem_stage (
    input wire clk,
    input wire mem_read,
    input wire mem_write,
    input wire [63:0] address,
    input wire [63:0] write_data,
    output wire [63:0] read_data
);

    // Data memory
    data_memory dmem (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

endmodule 