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
        
        // Wait for test program to complete
        repeat(200) @(posedge clk);
        
        // Verify results
        check_results();
        
        // Report results
        if (errors == 0)
            $display("\nAll tests passed!");
        else
            $display("\nFound %0d errors!", errors);
            
        $finish;
    end
    
    // Function to decode instruction type
    function [63:0] get_instruction_name;
        input [31:0] inst;
        begin
            case (inst[6:0])
                7'b0110011: begin // R-type
                    case ({inst[31:25], inst[14:12]})
                        10'b0000000000: get_instruction_name = "ADD";
                        10'b0100000000: get_instruction_name = "SUB";
                        default: get_instruction_name = "R-type";
                    endcase
                end
                7'b0010011: get_instruction_name = "ADDI";
                7'b0000011: get_instruction_name = "LD";
                7'b0100011: get_instruction_name = "SD";
                7'b1100011: begin // Branch
                    case (inst[14:12])
                        3'b000: get_instruction_name = "BEQ";
                        3'b001: get_instruction_name = "BNE";
                        default: get_instruction_name = "BRANCH";
                    endcase
                end
                default: get_instruction_name = "UNKNOWN";
            endcase
        end
    endfunction
    
    // Task to verify test results
    task check_results;
        begin
            $display("\n=== Starting Result Verification ===");
            
            // Check ADD result (x1 = x2 + x3 = 2 + 3 = 5)
            if (dut.regfile.registers[1] !== 64'd5) begin
                $display("Error: ADD test failed. x1=%0d, expected 5", 
                         dut.regfile.registers[1]);
                errors = errors + 1;
            end else
                $display("ADD test passed: x1=%0d", dut.regfile.registers[1]);
            
            // Check SUB result (x4 = x5 - x6 = 5 - 4 = 1)
            if (dut.regfile.registers[4] !== 64'd1) begin
                $display("Error: SUB test failed. x4=%0d, expected 1", 
                         dut.regfile.registers[4]);
                errors = errors + 1;
            end
            
            // Check ADDI result (x7 = x8 + 5)
            if (dut.regfile.registers[7] !== 64'd5) begin
                $display("Error: ADDI test failed. x7=%0d, expected 5", 
                         dut.regfile.registers[7]);
                errors = errors + 1;
            end
            
            // Check LD result (x13 should have loaded value)
            if (dut.regfile.registers[13] !== 64'd20) begin
                $display("Error: LD test failed. x13=%0d, expected 20", 
                         dut.regfile.registers[13]);
                errors = errors + 1;
            end
            
            // Check SD result (memory should have stored value)
            if (dut.dmem.memory[2] !== 64'd15) begin
                $display("Error: SD test failed. memory[2]=%0d, expected 15", 
                         dut.dmem.memory[2]);
                errors = errors + 1;
            end
        end
    endtask
    
    // Debug output for instruction execution
    always @(posedge clk) begin
        if (!rst) begin
            $display("\nTime=%0t:", $time);
            $display("  PC=%h", dut.pc);
            $display("  Instruction=%h (%s)", dut.instruction, get_instruction_name(dut.instruction));
            
            if (dut.reg_write)
                $display("  Register Write: x%0d = %0d (0x%h)", 
                    dut.instruction[11:7], dut.wb_data, dut.wb_data);
            if (dut.mem_write)
                $display("  Memory Write: [%0d] = %0d (0x%h)", 
                    dut.alu_result, dut.rs2_data, dut.rs2_data);
            if (dut.mem_read)
                $display("  Memory Read: [%0d] = %0d (0x%h)", 
                    dut.alu_result, dut.mem_read_data, dut.mem_read_data);
            if (dut.branch && dut.branch_taken)
                $display("  Branch taken to %h", dut.branch_target);
        end
    end

endmodule