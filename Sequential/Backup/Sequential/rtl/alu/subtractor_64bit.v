// 64 bit reg sub using 64 bit adder (2's comp)
module subtractor_64bit(

    input [63:0] a,
    input [63:0] b,
    output [63:0] diff

);

    wire [63:0] b_complement;
    wire cout;
    
    // create 2's comp of b
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin : complement
            not(b_complement[i], b[i]);
        end
    endgenerate
    
    // add + 1
    adder_64bit final(
        .a(a),
        .b(b_complement),
        .cin(1'b1),
        .sum(diff),
        .cout(cout)
    );

endmodule