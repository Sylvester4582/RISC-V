module instruction_memory (
    input wire [63:0] pc,
    output reg [31:0] instruction
);
    reg [31:0] memory [0:1023];  // 1024 instructions max
    
    // Bubble sort program
    initial begin
     
        memory[0]  = 32'h00000033;  // add x0, x0, x0
        memory[1]  = 32'h00000533;  // add x10, x0, x0
        memory[2]  = 32'h00500313;  // addi x6, x0, 5
        
        // Store array [5,2,8,1,9]
        memory[3]  = 32'h00500293;  // addi x5, x0, 5
        memory[4]  = 32'h00553023;  // sd x5, 0(x10)
        memory[5]  = 32'h00200293;  // addi x5, x0, 2
        memory[6]  = 32'h00553423;  // sd x5, 8(x10)
        memory[7]  = 32'h00800293;  // addi x5, x0, 8
        memory[8]  = 32'h00553823;  // sd x5, 16(x10)
        memory[9]  = 32'h00100293;  // addi x5, x0, 1
        memory[10] = 32'h00553C23;  // sd x5, 24(x10)
        memory[11] = 32'h00900293;  // addi x5, x0, 9
        memory[12] = 32'h02553023;  // sd x5, 32(x10)
        
        // Outer loop initialization
        memory[13] = 32'h00000133;  // add x2, x0, x0
        
        // Outer loop comparison
        memory[14] = 32'h00610863;  // beq x2, x6, done
        
        // Inner loop initialization
        memory[15] = 32'h00010433;  // add x8, x2, x0
        
        // Inner loop comparison
        memory[16] = 32'h00640863;  // beq x8, x6, outer_inc
        
        // Load elements to compare
        memory[17] = 32'h00043983;  // ld x19, 0(x8)
        memory[18] = 32'h00843903;  // ld x18, 8(x8)
        
        // Compare and swap if needed
        memory[19] = 32'h41298733;  // sub x14, x19, x18
        memory[20] = 32'h00074863;  // beq x14, x0, skip_swap
        
        // Swap elements
        memory[21] = 32'h01243023;  // sd x18, 0(x8)
        memory[22] = 32'h01343423;  // sd x19, 8(x8)
        
        // Skip swap and increment j
        memory[23] = 32'h00840413;  // addi x8, x8, 8
        memory[24] = 32'hFE000AE3;  // beq x0, x0, inner_loop
        
        // Outer loop increment
        memory[25] = 32'h00110113;  // addi x2, x2, 1
        memory[26] = 32'hFE000AE3;  // beq x0, x0, outer_loop
        
        // Done - infinite loop
        memory[27] = 32'h00000063;  // beq x0, x0, done
    end
    
    // IF
    always @(*) begin
        instruction = memory[pc[11:2]];
    end

endmodule