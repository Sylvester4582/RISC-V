module alu(

    // 3-bit function code
    input [2:0] funct3,
    // 7-bit function code
    input [6:0] funct7,
    // First src register
    input [63:0] rs1,
    // Second src register
    input [63:0] rs2,
    // Target register
    output reg [63:0] rd

);

    wire [63:0] add_final;
    wire [63:0] sub_final;
    wire [63:0] and_final;
    wire [63:0] or_final;
    wire [63:0] xor_final;
    wire [63:0] sll_final;
    wire [63:0] srl_final;
    wire [63:0] sra_final;
    wire [63:0] slt_final;
    wire [63:0] sltu_final;

    // Decoder
    wire is_add = (funct3 == 3'b000) && (funct7 == 7'b0000000);
    wire is_sub = (funct3 == 3'b000) && (funct7 == 7'b0100000);
    wire is_xor = (funct3 == 3'b100) && (funct7 == 7'b0000000);
    wire is_or  = (funct3 == 3'b110) && (funct7 == 7'b0000000);
    wire is_and = (funct3 == 3'b111) && (funct7 == 7'b0000000);
    wire is_sll = (funct3 == 3'b001) && (funct7 == 7'b0000000);
    wire is_srl = (funct3 == 3'b101) && (funct7 == 7'b0000000);
    wire is_sra = (funct3 == 3'b101) && (funct7 == 7'b0100000);
    wire is_slt = (funct3 == 3'b010) && (funct7 == 7'b0000000);
    wire is_sltu = (funct3 == 3'b011) && (funct7 == 7'b0000000);

    // Output multiplexer
    always @(*) begin
        case (1'b1)
            is_add:  rd = add_final;
            is_sub:  rd = sub_final;
            is_xor:  rd = xor_final;
            is_or:   rd = or_final;
            is_and:  rd = and_final;
            is_sll:  rd = sll_final;
            is_srl:  rd = srl_final;
            is_sra:  rd = sra_final;
            is_slt:  rd = slt_final;
            is_sltu: rd = sltu_final;
            default: rd = add_final; // Default to add for all other operations including load/store
        endcase
        
        // Debug output to verify ALU operation
        $display("ALU Calculation: RS1=%h, RS2=%h, Result=%h", rs1, rs2, rd);
    end

    // 64 bit adder
    adder_64bit add(
        .a(rs1),
        .b(rs2),
        .cin(1'b0),
        .sum(add_final),
        .cout()
    );

    // 64 bit subtractor
    subtractor_64bit sub(
        .a(rs1),
        .b(rs2),
        .diff(sub_final)
    );

    // Logical operations
    logical_operators logical_operations(
        .a(rs1),
        .b(rs2),
        .and_final(and_final),
        .or_final(or_final),
        .xor_final(xor_final)
    );

    // Shift operations
    shift_operators shift_operations(
        .a(rs1),
        .b(rs2),
        .sll_final(sll_final),
        .srl_final(srl_final),
        .sra_final(sra_final)
    );

    // Comparison operations
    comparator comparison_operations(
        .a(rs1),
        .b(rs2),
        .slt_final(slt_final),
        .sltu_final(sltu_final)
    );

endmodule