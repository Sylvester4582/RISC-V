module core_tb;
    reg clk;
    reg rst;
    
    // Instantiate the core
    core dut (
        .clk(clk),
        .rst(rst)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initialize waveform dumping
        $dumpfile("core_tb.vcd");
        $dumpvars(0, core_tb);
        
        // Reset the processor
        rst = 1;
        #20;
        rst = 0;
        
        // Run for enough cycles to complete bubble sort
        // Assuming worst case: n^2 cycles for n=5 elements
        #2000;
        
        // End simulation
        $finish;
    end
    
    // Monitor memory for verification
    always @(posedge clk) begin
        if (!rst) begin
            // Monitor the first 5 memory locations (sorted array)
            $display("Memory[0] = %d", dut.dmem.memory[0]);
            $display("Memory[1] = %d", dut.dmem.memory[1]);
            $display("Memory[2] = %d", dut.dmem.memory[2]);
            $display("Memory[3] = %d", dut.dmem.memory[3]);
            $display("Memory[4] = %d", dut.dmem.memory[4]);
        end
    end

endmodule 