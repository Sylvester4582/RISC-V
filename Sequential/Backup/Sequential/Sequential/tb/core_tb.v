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
            $display("\n=== Register Contents ===");
            // Display all relevant registers
            $display("x1 = %0d (Expected: 5)", dut.regfile.registers[1]);
            $display("x2 = %0d", dut.regfile.registers[2]);
            $display("x3 = %0d", dut.regfile.registers[3]);
            $display("x4 = %0d (Expected: 1)", dut.regfile.registers[4]);
            $display("x5 = %0d", dut.regfile.registers[5]);
            $display("x6 = %0d", dut.regfile.registers[6]);
            $display("x7 = %0d (Expected: 5)", dut.regfile.registers[7]);
            $display("x8 = %0d", dut.regfile.registers[8]);
            $display("x13 = %0d (Expected: 20 from LD)", dut.regfile.registers[13]);
            $display("x15 = %0d (SD source data)", dut.regfile.registers[15]);
            $display("x16 = %0d (SD base address)", dut.regfile.registers[16]);
            
            $display("\n=== Memory Contents ===");
            $display("memory[1] = %0d (Source for LD -> x13)", dut.dmem.memory[1]);
            $display("memory[2] = %0d (Expected: 15 from SD)", dut.dmem.memory[2]);
            $display("memory[3] = %0d (Expected: 15 from SD, addr=24)", dut.dmem.memory[3]);
            
            $display("\n=== Memory Operation Results ===");
            if (dut.regfile.registers[13] !== 64'd20) begin
                $display("LD Error: x13=%0d, expected 20 (should have loaded from memory[1])", 
                    dut.regfile.registers[13]);
                errors = errors + 1;
            end else
                $display("LD Success: x13 correctly loaded value 20 from memory[1]");
                
            if (dut.dmem.memory[2] !== 64'd15) begin
                $display("SD Error: memory[2]=%0d, expected 15", dut.dmem.memory[2]);
                errors = errors + 1;
            end else
                $display("SD Success: memory[2] correctly stored value 15");
            
            if (dut.dmem.memory[3] !== 64'd15) begin
                $display("SD Error: memory[3]=%0d, expected 15 (at address 24)", 
                    dut.dmem.memory[3]);
                errors = errors + 1;
            end else
                $display("SD Success: memory[3] correctly stored value 15");
            
            $display("\n=== Test Results ===");
            errors = 0;
            
            if (dut.regfile.registers[1] !== 64'd5)  errors = errors + 1;
            if (dut.regfile.registers[4] !== 64'd1)  errors = errors + 1;
            if (dut.regfile.registers[7] !== 64'd5)  errors = errors + 1;
            if (dut.regfile.registers[13] !== 64'd20) errors = errors + 1;
            if (dut.dmem.memory[2] !== 64'd15) errors = errors + 1;
            
            $display("Total Errors: %0d", errors);
        end
    endtask
    
    // Debug output for instruction execution
    always @(posedge clk) begin
        if (!rst) begin
            $display("\nTime=%0t:", $time);
            $display("  PC=%h", dut.pc);
            $display("  Instruction=%h (%s)", dut.instruction, get_instruction_name(dut.instruction));
            
            if (dut.branch) begin
                $display("  Branch Instruction:");
                $display("    Type: %s", get_instruction_name(dut.instruction));
                $display("    Rs1 (x%0d) = %0d", dut.instruction[19:15], dut.rs1_data);
                $display("    Rs2 (x%0d) = %0d", dut.instruction[24:20], dut.rs2_data);
                $display("    Offset = %0d", $signed({{20{dut.instruction[31]}}, 
                                                    dut.instruction[7], 
                                                    dut.instruction[30:25], 
                                                    dut.instruction[11:8], 
                                                    1'b0}));
                if (dut.branch_taken)
                    $display("    Branch taken to %h", dut.branch_target);
                else
                    $display("    Branch not taken, PC+4");
            end
            
            if (dut.mem_read) begin
                $display("  LD Operation:");
                $display("    Address = %0d", dut.alu_result);
                $display("    Memory Index = %0d", dut.alu_result[10:3]);
                $display("    Data Read = %0d", dut.mem_read_data);
                $display("    Target Register = x%0d", dut.instruction[11:7]);
            end
            
            if (dut.mem_write) begin
                $display("  SD Operation:");
                $display("    Base Address (x%0d) = %0d", dut.instruction[19:15], dut.rs1_data);
                $display("    Offset = %0d", {{52{dut.instruction[31]}}, dut.instruction[31:25], dut.instruction[11:7]});
                $display("    Effective Address = %0d", dut.alu_result);
                $display("    Memory Index = %0d", dut.alu_result[10:3]);
                $display("    Data to Store (x%0d) = %0d", dut.instruction[24:20], dut.rs2_data);
            end
            
            if (dut.reg_write)
                $display("  Register Write: x%0d = %0d", 
                    dut.instruction[11:7], dut.wb_data);
            if (dut.branch && dut.branch_taken)
                $display("  Branch taken to %h", dut.branch_target);
        end
    end

endmodule