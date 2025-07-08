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

    // Decoder
    wire is_add = (funct3 == 3'b000) && (funct7 == 7'b0000000);
    wire is_sub = (funct3 == 3'b000) && (funct7 == 7'b0100000);
    wire is_xor = (funct3 == 3'b100) && (funct7 == 7'b0000000);
    wire is_or  = (funct3 == 3'b110) && (funct7 == 7'b0000000);
    wire is_and = (funct3 == 3'b111) && (funct7 == 7'b0000000);

    // Output multiplexer
    always @(*) begin
        case (1'b1)
            is_add:  rd = add_final;
            is_sub:  rd = sub_final;
            is_xor:  rd = xor_final;
            is_or:   rd = or_final;
            is_and:  rd = and_final;
            default: rd = add_final;
        endcase
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

endmodule