module main_tb;
    reg clk;
    reg rst;
    integer cycle_count;

    // VCD dump setup
    initial begin
             
        // Dump VCD file to results folder
        $dumpfile("results/main_tb.vcd");
        $dumpvars(0, main_tb);
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    main dut (
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
        
        // Display initial register state after reset
        $display("\n~~~~~~~~~ Initial Register State ~~~~~~~~~");
        for (integer i = 0; i < 32; i = i + 1) begin
            $display("x%0d = %0d (0x%h)", i, dut.regfile.registers[i], dut.regfile.registers[i]);
        end
        
        // Display initial memory state
        $display("\n~~~~~~~~~ Initial Memory State [0-9] ~~~~~~~~~");
        for (integer i = 0; i <= 10; i = i + 1) begin
            $display("Memory[%0d] = %0d (0x%h)", i, dut.dmem.memory[i], dut.dmem.memory[i]);
        end
        
        $display("\n------------------------------------------------------\n");
        
        #10;
        
        // Wait for 20 instructions then finish (for now)
        repeat(20) @(posedge clk);
        
        // Display final register state ( EOF )
        $display("\n~~~~~~~~~ Final Register State ~~~~~~~~~");
        for (integer i = 0; i < 32; i = i + 1) begin
            $display("x%0d = %0d (0x%h)", i, dut.regfile.registers[i], dut.regfile.registers[i]);
        end
        
        // Display final memory state
        $display("\n~~~~~~~~~ Final Memory State [0-9] ~~~~~~~~~");
        for (integer i = 0; i < 10; i = i + 1) begin
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
                        10'b0000000111: instruction = "AND";
                        10'b0000000110: instruction = "OR";
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
            
            // IF Stage
            $display("IF Stage:");
            $display("PC: 0x%h", dut.if_pc);
            $display("Instruction: 0x%h (%s)", dut.if_instruction, instruction(dut.if_instruction));
            
            // ID Stage
            $display("\nID Stage:");
            $display("Instruction: 0x%h (%s)", dut.pipe_regs.id_instruction, 
                    instruction(dut.pipe_regs.id_instruction));
            if (dut.stall_id) $display("ID Stage Stalled");
            
            // EX Stage
            $display("\nEX Stage:");
            $display("ALU Operation: %s", instruction(dut.pipe_regs.id_instruction));
            $display("RS1 Data: %0d (0x%h)", dut.ex_rs1_data_fwd, dut.ex_rs1_data_fwd);
            $display("RS2 Data: %0d (0x%h)", dut.ex_rs2_data_fwd, dut.ex_rs2_data_fwd);
            if (dut.flush_ex) $display("EX Stage Flushed");
            
            // MEM Stage
            $display("\nMEM Stage:");
            if (dut.pipe_regs.mem_mem_read)
                $display("Memory Read: Address=0x%h Data=%0d", 
                        dut.pipe_regs.mem_alu_result, dut.mem_read_data);
            if (dut.pipe_regs.mem_mem_write)
                $display("Memory Write: Address=0x%h Data=%0d", 
                        dut.pipe_regs.mem_alu_result, dut.pipe_regs.mem_write_data);
            
            // WB Stage
            $display("\nWB Stage:");
            if (dut.pipe_regs.wb_reg_write)
                $display("Register Write: x%0d = %0d (0x%h)", 
                        dut.pipe_regs.wb_rd_addr, dut.wb_data, dut.wb_data);
            
            // Hazard and Forwarding Information
            $display("\nHazard/Forward Info:");
            $display("Forward A: %b", dut.forward_a);
            $display("Forward B: %b", dut.forward_b);
            if (dut.stall_if || dut.stall_id || dut.flush_ex)
                $display("Pipeline Hazard Detected");
            
            $display("\n------------------------------------------------------");
        end else begin
            prev_reg_write <= 0;
        end
    end

endmodule