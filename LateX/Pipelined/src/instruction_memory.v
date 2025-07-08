// Instruction Memory - Stores and provides program instructions
// - Holds upto 128 32-bit instructions
// - Word-aligned access
// - Loads program from testcase file, can be taken form testcase_bank.txt
// - Initializes with NOP instructions

module instruction_memory (
    input wire [63:0] pc,
    output reg [31:0] instruction
);
    // 128 instructions
    reg [31:0] memory [0:127];
    integer i;
    
    initial begin
        // Initialize with NOPs
        for (i = 0; i < 128; i = i + 1) begin
            memory[i] = 32'h00000013;  // NOP
        end
        
        // Read instructions from file
        $readmemb("testcase.txt", memory);
        
        // Display instructions in binary and decode key fields
        $display("\nInstruction memory contents:\n");
        for (i = 0; i < 10; i = i + 1) begin
            $display("Instruction Memory[%0d] = %b (hex: %h)", i, memory[i], memory[i]);
            $display("  rs1=%d, rs2=%d, opcode=%b", 
                     memory[i][19:15], memory[i][24:20], memory[i][6:0]);
        end
    end
    
    // Read operation
    always @(*) begin
        instruction = memory[pc[8:2]];  // Word-aligned access
    end

endmodule