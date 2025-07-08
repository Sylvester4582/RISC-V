module proc_tb;
    reg clk;
    reg rst;
    
    // Instantiate the processor
    core proc (
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
        $dumpfile("proc.vcd");
        $dumpvars(0, proc_tb);
        
        // Reset the processor
        rst = 1;
        @(posedge clk);
        @(posedge clk);
        rst = 0;
        
        // Wait for program to complete
        // Assuming array of 5 numbers, worst case is 4 passes * 5 comparisons * instructions per comparison
        repeat(200) @(posedge clk);
        
        // Check results using the test interface
        if (proc.dmem.get_word(0) == 64'd1 &&
            proc.dmem.get_word(1) == 64'd2 &&
            proc.dmem.get_word(2) == 64'd3 &&
            proc.dmem.get_word(3) == 64'd4 &&
            proc.dmem.get_word(4) == 64'd5) begin
            $display("TEST PASSED: Array sorted correctly!");
            $display("Final array: [%0d, %0d, %0d, %0d, %0d]",
                    proc.dmem.get_word(0),
                    proc.dmem.get_word(1),
                    proc.dmem.get_word(2),
                    proc.dmem.get_word(3),
                    proc.dmem.get_word(4));
        end else begin
            $display("TEST FAILED: Array not sorted!");
            $display("Final array: [%0d, %0d, %0d, %0d, %0d]",
                    proc.dmem.get_word(0),
                    proc.dmem.get_word(1),
                    proc.dmem.get_word(2),
                    proc.dmem.get_word(3),
                    proc.dmem.get_word(4));
        end
        
        $finish;
    end
endmodule 