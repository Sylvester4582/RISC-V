// 1 bit adder
module full_adder(

    input a,
    input b,
    input cin,
    output sum,
    output cout

);

    wire temp1, temp2, temp3;
    // sum
    xor(temp1, a, b);
    xor(sum, temp1, cin);
    // cout : (a && b) || (cin && (a ^ b))
    and(temp2, a, b);
    and(temp3, cin, temp1);
    or(cout, temp2, temp3);

endmodule