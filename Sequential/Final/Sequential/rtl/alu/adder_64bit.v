// 64 bit reg adder using 1 bit block
module adder_64bit(

    input [63:0] a,
    input [63:0] b,
    input cin,
    output [63:0] sum,
    output cout

);

    wire [64:0] carry; // 1 extra bit for overflow
    assign carry[0] = cin;
    genvar i;

    generate
        for(i = 0; i < 64; i = i +1) begin : adders
            full_adder fa(
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate
    
    // used for overflow flag later
    assign cout = carry[64];

endmodule