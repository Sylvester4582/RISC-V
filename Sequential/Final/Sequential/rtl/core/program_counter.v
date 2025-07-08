// PC - Manages instruction address sequencing
// - Maintains current instruction address
// - Handles sequential instruction progression
// - Processes branch target updates
// - Manages program termination
// - Provides reset functionality

module program_counter (
    input wire clk,
    input wire rst,
    input wire branch,
    input wire [63:0] branch_target,
    output reg [63:0] pc
);

    // Maximum PC value (128 instructions * 4 bytes)
    localparam MAX_PC = 64'h0000_0000_0000_0200;

    initial begin
        pc = 64'h0;
        $display("PC initialized to 0x%h", pc);
    end

    always @(posedge clk) begin
        if (rst) begin
            pc <= 64'h0;
            $display("PC: Reset to 0x%h", 64'h0);
        end else if (branch) begin
            pc <= branch_target;
            $display("PC: Branch taken to 0x%h", branch_target);
        end else if (pc < MAX_PC - 4) begin
            pc <= pc + 4;
            $display("PC: Normal increment to 0x%h", pc + 4);
        end else begin
            $display("Program completed: PC reached maximum value (0x%h)", MAX_PC);
            $finish;
        end
    end

endmodule