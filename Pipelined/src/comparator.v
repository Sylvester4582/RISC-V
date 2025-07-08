// comparison operations
// gate-bit level implementation
module comparator(

    input [63:0] a,
    input [63:0] b,
    output [63:0] slt_final,
    output [63:0] sltu_final

);
    wire [63:0] sub;
    wire is_less_s;
    wire is_less_u;
    wire [62:0] zeros;
    wire diff_sign;
    wire a_neg;

    // unsigned calc
    wire [63:0] eq; 
    wire [63:0] gt;  
    wire [63:0] lt;   
    wire [64:0] prop; 
    wire [63:0] lt_temp;
    
    subtractor_64bit compare(
        .a(a),
        .b(b),
        .diff(sub)
    );
    
    // gate-level signed comparison
    xor sign_gate(diff_sign, a[63], b[63]);
    and neg_gate(a_neg, a[63], ~b[63]);
    
    // gate-level unsigned comparison
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin : compare_each_bit
            xnor eq_gate(eq[i], a[i], b[i]);
            and  lt_gate(lt[i], ~a[i], b[i]);
            and  gt_gate(gt[i], a[i], ~b[i]);
        end
    endgenerate

    assign prop[64] = 1'b0;
    
    generate
        for(i = 63; i >= 0; i = i - 1) begin : priority
            and prop_gate(prop[i], eq[i], prop[i+1]);
            or  final_gate(lt_temp[i], lt[i], prop[i+1] & lt[i]);
        end
    endgenerate
    
    // if sign is same, use subtraction result
    wire sub_neg;
    wire same_less;
    and sub_gate(sub_neg, sub[63], 1'b1);
    and same_gate(same_less, ~diff_sign, sub_neg);
    or less_gate(is_less_s, a_neg, same_less);
    
    // unsigned
    assign is_less_u = lt_temp[0];

    assign zeros = 63'b0;
    // 1 or 0 in 64 bit
    assign slt_final = {zeros, is_less_s};
    assign sltu_final = {zeros, is_less_u};

endmodule