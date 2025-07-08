// sll , slr , sla
module shift_operators(

    input [63:0] a,
    input [63:0] b, // <= 5 (63 times max shift)
    output reg [63:0] sll_final,
    output reg [63:0] srl_final,
    output reg [63:0] sra_final

);
    
    reg [63:0] temp_sll;
    reg [63:0] temp_srl;
    reg [63:0] temp_sra;
    
    always @(*) begin

        temp_sll = a;
        temp_srl = a;
        temp_sra = a;
        
        // Check if shift amount >= 64
        if (|b[63:6]) begin
            temp_sll = 64'b0;
            temp_srl = 64'b0;
            temp_sra = {64{a[63]}};
        end
        else begin
            // sll
            if (b[0]) temp_sll = {temp_sll[62:0], 1'b0};
            if (b[1]) temp_sll = {temp_sll[61:0], 2'b0};
            if (b[2]) temp_sll = {temp_sll[59:0], 4'b0};
            if (b[3]) temp_sll = {temp_sll[55:0], 8'b0};
            if (b[4]) temp_sll = {temp_sll[47:0], 16'b0};
            if (b[5]) temp_sll = {temp_sll[31:0], 32'b0};
            
            // slr
            if (b[0]) temp_srl = {1'b0, temp_srl[63:1]};
            if (b[1]) temp_srl = {2'b0, temp_srl[63:2]};
            if (b[2]) temp_srl = {4'b0, temp_srl[63:4]};
            if (b[3]) temp_srl = {8'b0, temp_srl[63:8]};
            if (b[4]) temp_srl = {16'b0, temp_srl[63:16]};
            if (b[5]) temp_srl = {32'b0, temp_srl[63:32]};
            
            // sra
            if (b[0]) temp_sra = {temp_sra[63], temp_sra[63:1]};
            if (b[1]) temp_sra = {{2{temp_sra[63]}}, temp_sra[63:2]};
            if (b[2]) temp_sra = {{4{temp_sra[63]}}, temp_sra[63:4]};
            if (b[3]) temp_sra = {{8{temp_sra[63]}}, temp_sra[63:8]};
            if (b[4]) temp_sra = {{16{temp_sra[63]}}, temp_sra[63:16]};
            if (b[5]) temp_sra = {{32{temp_sra[63]}}, temp_sra[63:32]};
        end

        sll_final = temp_sll;
        srl_final = temp_srl;
        sra_final = temp_sra;
    end

endmodule