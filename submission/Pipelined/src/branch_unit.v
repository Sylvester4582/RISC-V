module branch_unit (
    input wire [63:0] rs1_data,        // First source register
    input wire [63:0] rs2_data,        // Second source register
    input wire branch,                 // Branch instruction signal from control
    input wire [2:0] funct3,          // Branch type (BEQ, BNE)
    input wire [63:0] pc,             // Current PC
    input wire [63:0] imm,            // Branch immediate
    output reg take_branch,           // Branch decision
    output reg [63:0] branch_target   // Branch target address
);

    // Branch comparison logic
    wire equal = (rs1_data == rs2_data);
    
    // Track previous branch decisions to avoid duplicate messages
    reg prev_branch;
    reg [63:0] prev_pc;
    reg prev_take_branch;
    
    initial begin
        prev_branch = 1'b0;
        prev_pc = 64'hFFFFFFFFFFFFFFFF;
        prev_take_branch = 1'b0;
    end
    
    // Calculate branch target and decision
    always @(*) begin
        // Default values
        take_branch = 1'b0;
        branch_target = pc + imm;  // Calculate target using ID stage PC
        
        if (branch) begin
            case (funct3)
                3'b000: begin // BEQ
                    take_branch = equal;
                end
                3'b001: begin // BNE
                    take_branch = !equal;
                end
                default: begin
                    take_branch = 1'b0;
                end
            endcase
            
            // Only display branch info once when a branch is actually taken
            // and avoid duplicate messages for the same PC
            if (take_branch && (prev_pc != pc || prev_branch != branch || prev_take_branch != take_branch)) begin
                case (funct3)
                    3'b000: $display("[BRANCH] BEQ taken: PC=0x%h → 0x%h (rs1=0x%h == rs2=0x%h)", 
                                    pc, branch_target, rs1_data, rs2_data);
                    3'b001: $display("[BRANCH] BNE taken: PC=0x%h → 0x%h (rs1=0x%h != rs2=0x%h)", 
                                    pc, branch_target, rs1_data, rs2_data);
                    default: $display("[BRANCH] Unknown branch type: funct3=%b", funct3);
                endcase
                
                // Update previous values
                prev_pc = pc;
                prev_branch = branch;
                prev_take_branch = take_branch;
            end
        end else begin
            // Reset tracking when not a branch instruction
            prev_branch = 1'b0;
        end
    end

endmodule