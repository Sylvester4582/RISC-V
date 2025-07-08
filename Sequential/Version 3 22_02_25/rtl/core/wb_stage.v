// Writeback Stage - Selects data to write to registers
// - Multiplexes between memory and ALU results
// - Forwards selected data to register file
// - Handles data selection based on instruction type
// - Provides final computation result

module wb_stage (
    input wire [63:0] mem_read_data,
    input wire [63:0] alu_result,
    input wire mem_read,
    output wire [63:0] wb_data
);
    // Select write-back data
    assign wb_data = mem_read ? mem_read_data : alu_result;

    // Debug output
    always @(*) begin
        if (mem_read)
            $display("WB: From memory: %h", mem_read_data);
        else
            $display("WB: From ALU: %h", alu_result);
    end
endmodule 