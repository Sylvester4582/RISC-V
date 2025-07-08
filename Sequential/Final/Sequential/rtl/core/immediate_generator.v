// Immediate Generator - Extracts and sign-extends immediate values
// - Handles I-type immediates (load, arithmetic)
// - Handles S-type immediates (store)
// - Handles B-type immediates (branch)
// - Performs proper sign extension to 64 bits
// - Assembles immediates from instruction fields

module immediate_generator (
    input wire [31:0] instruction,
    input wire [2:0] imm_type,
    output reg [63:0] immediate
);
    // Immediate type encodings
    localparam IMM_I = 3'b000;  // I-type (ld, addi)
    localparam IMM_S = 3'b001;  // S-type (sd)
    localparam IMM_B = 3'b010;  // B-type (beq)
    
    wire [11:0] i_imm;
    wire [11:0] s_imm;
    wire [12:0] b_imm;
    
    assign i_imm = instruction[31:20];
    assign s_imm = {instruction[31:25], instruction[11:7]};
    assign b_imm = {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
    
    // Sign extension and immediate selection
    always @(*) begin
        case (imm_type)
            IMM_I: immediate = {{52{instruction[31]}}, instruction[31:20]};
            IMM_S: immediate = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]};
            IMM_B: immediate = {{52{instruction[31]}}, instruction[7], instruction[30:25], 
                               instruction[11:8]};
            default: immediate = 64'b0;
        endcase
        
        $display("Immediate Generator: type=%b value=%h", imm_type, immediate);
    end

endmodule 