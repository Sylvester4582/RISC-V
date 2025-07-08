module if_stage (
    input wire clk,
    input wire rst,
    input wire branch,
    input wire [63:0] branch_target,
    output wire [63:0] pc,
    output wire [31:0] instruction
);

    // Program counter
    program_counter pc_unit (
        .clk(clk),
        .rst(rst),
        .branch(branch),
        .branch_target(branch_target),
        .pc(pc)
    );
    
    // Instruction memory
    instruction_memory imem (
        .pc(pc),
        .instruction(instruction)
    );

endmodule 