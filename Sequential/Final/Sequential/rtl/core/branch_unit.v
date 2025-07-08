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
    
    // Calculate branch target
    always @(*) begin

        take_branch = 1'b0;
        branch_target = pc + imm;
        
        if (branch) begin
            case (funct3)
                3'b000: begin 
                    take_branch = equal;
                    $display("BEQ: rs1=%0d (0x%h) rs2=%0d (0x%h) equal=%b target=0x%h", 
                        rs1_data, rs1_data,
                        rs2_data, rs2_data,
                        equal,
                        branch_target);
                end
                3'b001: begin
                    take_branch = !equal;
                    $display("BNE: rs1=%0d (0x%h) rs2=%0d (0x%h) not_equal=%b target=0x%h", 
                        rs1_data, rs1_data,
                        rs2_data, rs2_data,
                        !equal,
                        branch_target);
                end
                default: begin
                    take_branch = 1'b0;
                    $display("Unknown branch type funct3=%b", funct3);
                end
            endcase
        end
    end

endmodule