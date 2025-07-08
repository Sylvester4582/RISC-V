// Fetch Stage - Retrieves instructions from memory
// - Manages program counter updates
// - Interfaces with instruction memory
// - Handles branch redirection
// - Provides instructions to decode stage
// - Controls instruction sequencing

module if_stage (
    input wire clk,
    input wire rst,
    input wire branch_taken,
    input wire [63:0] branch_target,
    output wire [63:0] pc,
    output wire [31:0] instruction
);

    // Program counter
    program_counter pc_unit (
        .clk(clk),
        .rst(rst),
        .branch(branch_taken),
        .branch_target(branch_target),
        .pc(pc)
    );
    
    // Instruction memory
    instruction_memory imem (
        .pc(pc),
        .instruction(instruction)
    );

endmodule 