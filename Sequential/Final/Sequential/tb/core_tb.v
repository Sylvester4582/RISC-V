module core_tb;
    reg clk;
    reg rst;
    integer cycle_count;

    // VCD dump setup
    initial begin
             
        // Dump VCD file to results folder
        $dumpfile("results/core_tb.vcd");
        $dumpvars(0, core_tb);
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    core dut (
        .clk(clk),
        .rst(rst)
    );
    
    // Test
    initial begin
       
        cycle_count = 0;
        
        // Rst
        rst = 1;
        #20;
        rst = 0;
        #10;
        
        // Wait for 20 instructions then finish (for now)
        repeat(20) @(posedge clk);
        
        // Display final register state ( EOF )
        $display("\n~~~~~~~~~ Final Register State ~~~~~~~~~");
        for (integer i = 0; i < 32; i = i + 1) begin
            $display("x%0d = %0d (0x%h)", i, dut.regfile.registers[i], dut.regfile.registers[i]);
        end
        
        // Display final memory state
        $display("\n~~~~~~~~~ Final Memory State [1-10] ~~~~~~~~~");
        for (integer i = 1; i <= 10; i = i + 1) begin
            $display("Memory[%0d] = %0d (0x%h)", i, dut.dmem.memory[i], dut.dmem.memory[i]);
        end
        
        $finish;
    end
    
    // Function to decode instruction type
    function [63:0] instruction;
        input [31:0] inst;
        begin
            case (inst[6:0])
                7'b0110011: begin // R-type
                    case ({inst[31:25], inst[14:12]})
                        10'b0000000000: instruction = "ADD";
                        10'b0100000000: instruction = "SUB";
                        default: instruction = "R-type";
                    endcase
                end
                7'b0010011: instruction = "ADDI";
                7'b0000011: instruction = "LD";
                7'b0100011: instruction = "SD";
                7'b1100011: begin // Branch
                    case (inst[14:12])
                        3'b000: instruction = "BEQ";
                        3'b001: instruction = "BNE";
                        default: instruction = "BRANCH";
                    endcase
                end
                default: instruction = "UNKNOWN?";
            endcase
        end
    endfunction
    
   
    reg prev_reg_write;
    reg [4:0] prev_write_reg;
    reg [63:0] prev_write_data;
    
    always @(negedge clk) begin
        if (!rst) begin
            cycle_count = cycle_count + 1;
            
            $display("\n~~~~~ Cycle %0d ~~~~~", cycle_count);
            $display("PC: 0x%h", dut.pc);
            $display("Instruction is: 0x%h (%s)", dut.instruction, instruction(dut.instruction));
            
            // Display register state
            $display("\nRegister Values:");
            for (integer i = 0; i < 32; i = i + 1) begin
                $display("x%0d = %0d (0x%h)", i, dut.regfile.registers[i], dut.regfile.registers[i]);
            end
            
            // Operation display
            if (dut.mem_read) begin
                $display("\nLoad Operation Details:");
                $display("Base Register (x%0d) = %0d", dut.instruction[19:15], dut.rs1_data);
                $display("Immediate Offset = %0d", $signed({{52{dut.instruction[31]}}, dut.instruction[31:20]}));
                $display("Effective Address = Base(%0d) + Offset(%0d) = %0d", 
                    dut.rs1_data,
                    $signed({{52{dut.instruction[31]}}, dut.instruction[31:20]}),
                    dut.alu_result);
                $display("Memory Word Index = %0d", dut.alu_result[10:3]);
                $display("Value Loaded = %0d", dut.mem_read_data);
                $display("Target Register = x%0d", dut.instruction[11:7]);
            end
                    
            
            if (dut.mem_write) begin
                $display("\nStore Operation Details:");
                $display("Base Register (x%0d) = %0d", dut.instruction[19:15], dut.rs1_data);
                $display("Immediate Offset = %0d", 
                    $signed({{52{dut.instruction[31]}}, dut.instruction[31:25], dut.instruction[11:7]}));
                $display("Source Register (x%0d) = %0d", dut.instruction[24:20], dut.rs2_data);
                $display("Effective Address = Base(%0d) + Offset(%0d) = %0d",
                    dut.rs1_data,
                    $signed({{52{dut.instruction[31]}}, dut.instruction[31:25], dut.instruction[11:7]}),
                    dut.alu_result);
                $display("Memory Word Index = %0d", dut.alu_result[10:3]);
                $display("Writing Value %0d from x%0d to memory[%0d]", 
                    dut.rs2_data, 
                    dut.instruction[24:20], 
                    dut.alu_result[10:3]);
                
            
                $display("\nMemory State Around Write Location:");
                for (integer i = -1; i <= 1; i = i + 1) begin
                    if ((dut.alu_result[10:3] + i) >= 0) begin
                        $display("memory[%0d] = %0d (0x%h)", 
                            dut.alu_result[10:3] + i, 
                            dut.dmem.memory[dut.alu_result[10:3] + i],
                            dut.dmem.memory[dut.alu_result[10:3] + i]);
                    end
                end
            end
            
            
            if (dut.branch) begin
                $display("\nBranch Operation Details:");
                $display("Branch Type: %s", instruction(dut.instruction));
                $display("RS1 (x%0d) = %0d", dut.instruction[19:15], dut.rs1_data);
                $display("RS2 (x%0d) = %0d", dut.instruction[24:20], dut.rs2_data);
                $display("Branch Immediate = %0d", $signed({{52{dut.instruction[31]}}, 
                    dut.instruction[7], 
                    dut.instruction[30:25], 
                    dut.instruction[11:8]}));
                $display("Current PC = 0x%h", dut.pc);
                $display("Branch Target = 0x%h", dut.branch_target);
                $display("Branch Taken: %s", dut.branch_taken ? "Yes" : "No");
                if (dut.branch_taken) begin
                    $display("Next PC will be: 0x%h", dut.branch_target);
                end else begin
                    $display("Next PC will be: 0x%h", dut.pc + 4);
                end
            end
            
            // Previous cycle write result
            if (prev_reg_write) begin
                $display("\nPrevious Cycle Register Write Result:");
                $display("Wrote %0d (0x%h) to x%0d", 
                    prev_write_data,
                    prev_write_data,
                    prev_write_reg);
            end
            
            // Current write
            prev_reg_write <= dut.reg_write;
            prev_write_reg <= dut.instruction[11:7];
            prev_write_data <= dut.wb_data;
            
            $display("\n------------------------------------------------------");
        end else begin
            prev_reg_write <= 0;
        end
    end

endmodule