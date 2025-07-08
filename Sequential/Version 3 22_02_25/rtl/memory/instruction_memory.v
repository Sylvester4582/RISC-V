// Instruction Memory - Stores and provides program instructions
// - Holds 128 32-bit instructions
// - Supports word-aligned access
// - Loads program from testcase file
// - Initializes with NOP instructions
// - Provides debug output functionality

module instruction_memory (
    input wire [63:0] pc,
    output reg [31:0] instruction
);
    reg [31:0] memory [0:127];  // 128 instructions
    integer i;
    
    initial begin
        // Initialize with NOPs
        for (i = 0; i < 128; i = i + 1) begin
            memory[i] = 32'h00000013;  // NOP
        end
        
        // Read instructions from testcase.txt with correct path
        $readmemb("./testcase.txt", memory);
        
        // Debug output
        $display("Instruction memory contents:");
        for (i = 0; i < 20; i = i + 1) begin
            $display("memory[%0d] = %b", i, memory[i]);
        end
    end
    
    always @(*) begin
        instruction = memory[pc[8:2]];  // Word-aligned access
        $display("Fetch: PC=%h Instruction=%h", pc, instruction);
    end

endmodule