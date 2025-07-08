// || && ^
module logical_operators(

    input [63:0] a,
    input [63:0] b,
    output [63:0] xor_final,
    output [63:0] and_final,
    output [63:0] or_final

);
    
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin : bitwiseops
            or(or_final[i], a[i], b[i]);
            and(and_final[i], a[i], b[i]);
            xor(xor_final[i], a[i], b[i]);
        end
    endgenerate

endmodule