// Branch Unit - Handles conditional branch operations
// - Compares register values for branch conditions
// - Calculates branch target address
// - Ensures proper instruction alignment
// - Supports BEQ and BNE instructions
// - Generates branch taken/not taken decision

module branch_unit (
    input wire [63:0] rs1_data,        // First source register
    input wire [63:0] rs2_data,        // Second source register
    input wire branch,                 // Branch instruction signal from control
    input wire [2:0] funct3,          // Branch type (BEQ, BNE, etc.)
    input wire [63:0] pc,             // Current PC
    input wire [63:0] imm,            // Branch immediate
    output reg take_branch,           // Branch decision
    output wire [63:0] branch_target  // Branch target address
);

    // Calculate branch target
    assign branch_target = pc + imm;

    // Validate branch target alignment
    wire [63:0] aligned_target = {branch_target[63:2], 2'b00};
    assign branch_target = aligned_target;  // Ensure 4-byte alignment

    // Branch comparison logic
    wire equal = (rs1_data == rs2_data);
    
    // Determine if branch should be taken
    always @(*) begin
        if (branch) begin
            case (funct3)
                3'b000: begin 
                    take_branch = equal;
                    $display("BEQ instruction: rs1=%h rs2=%h equal=%b", 
                             rs1_data, rs2_data, equal);
                end
                3'b001: begin
                    take_branch = !equal;
                    $display("BNE instruction: rs1=%h rs2=%h not_equal=%b", 
                             rs1_data, rs2_data, !equal);
                end
                default: begin
                    take_branch = 1'b0;
                    $display("Unsupported branch type: funct3=%b", funct3);
                end
            endcase
        end else begin
            take_branch = 1'b0;
        end
    end

endmodule 