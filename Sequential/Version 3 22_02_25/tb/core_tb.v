// Core Testbench - Verification environment for RISC-V processor
// - Generates clock and reset signals
// - Implements basic test sequences
// - Monitors control signals
// - Verifies bubble sort functionality
// - Checks memory contents
// - Reports test results

module core_tb;
    // Clock and reset
    reg clk;
    reg rst;
    
    // Test signals
    reg [4:0] rd, rs1, rs2;
    reg [63:0] expected_result;
    integer errors;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Instance of core
    core dut (
        .clk(clk),
        .rst(rst)
    );
    
    // Test stimulus
    initial begin
        // Initialize
        errors = 0;
        
        // Reset sequence
        rst = 1;
        #20;
        rst = 0;
        #10;
        
        // Wait for bubble sort to complete
        repeat(1000) @(posedge clk);
        
        // Check final sorted array
        check_sorted_array();
        
        // Report results
        if (errors == 0)
            $display("All tests passed!");
        else
            $display("Found %d errors!", errors);
            
        $finish;
    end
    
    // Task to check if array is sorted
    task check_sorted_array;
        reg [63:0] prev_value, curr_value;
        integer i;
        begin
            prev_value = dut.mem_stage_inst.dmem.memory[0];
            for (i = 1; i < 5; i = i + 1) begin
                curr_value = dut.mem_stage_inst.dmem.memory[i];
                if (curr_value < prev_value) begin
                    $display("Error: Array not sorted at index %0d", i);
                    errors = errors + 1;
                end
                prev_value = curr_value;
            end
        end
    endtask
    
    // Monitor key signals
    initial begin
        $monitor("Time=%0t rst=%0b rd=%0d rs1=%0d rs2=%0d",
                 $time, rst, rd, rs1, rs2);
    end

    // Monitor key signals
    always @(posedge clk) begin
        if (!rst) begin
            $display("Control Signals: mem_read=%b mem_write=%b reg_write=%b branch=%b",
                    dut.id_stage_inst.mem_read,
                    dut.id_stage_inst.mem_write,
                    dut.id_stage_inst.reg_write,
                    dut.id_stage_inst.branch);
        end
    end

endmodule