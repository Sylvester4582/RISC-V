module immediate_generator (
    input wire [31:0] instruction,
    input wire [2:0] imm_type,
    output reg [63:0] immediate
);
    // Immediate type encodings
    localparam IMM_I = 3'b000;  // I-type
    localparam IMM_S = 3'b001;  // S-type
    localparam IMM_B = 3'b010;  // B-type
    
    wire [11:0] i_imm = instruction[31:20];
    wire [11:0] s_imm = {instruction[31:25], instruction[11:7]};
    wire [12:0] b_imm = {instruction[31], instruction[7], 
                         instruction[30:25], instruction[11:8], 1'b0};
    
    // Sign extension
    always @(*) begin
        case (imm_type)
            IMM_I: immediate = {{52{i_imm[11]}}, i_imm};
            IMM_S: immediate = {{52{s_imm[11]}}, s_imm};
            IMM_B: immediate = {{51{b_imm[12]}}, b_imm};
            default: immediate = 64'b0;
        endcase
    end

endmodule 