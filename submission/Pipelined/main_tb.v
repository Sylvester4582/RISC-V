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
        #10;
        
        // Wait for 20 instructions then finish (for now)
        repeat(20) @(posedge clk);
        
        // Display final register state
        $display("\n==================== SIMULATION RESULTS ====================");
        $display("[FINAL] Register State:");
        for (integer i = 0; i < 32; i = i + 1) begin
            if (dut.regfile.registers[i] != 0 || i == 0)
                $display("    x%-2d = %10d (0x%16h)", i, dut.regfile.registers[i], dut.regfile.registers[i]);
        end
        
        // Display final memory state
        $display("\n[FINAL] Memory State [0-10]:");
        for (integer i = 0; i <= 10; i = i + 1) begin
            if (dut.dmem.memory[i] != 0 || i <= 3) // Always show first few locations
                $display("    Mem[%-3d] = %10d (0x%16h)", i, dut.dmem.memory[i], dut.dmem.memory[i]);
        end
        
        $display("============================================================\n");
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
            
            $display("\n[CYCLE %0d] ==============================", cycle_count);
            
            // IF Stage
            $display("  [IF] PC: 0x%h | Instr: 0x%08h (%s)", 
                    dut.if_pc, 
                    dut.if_instruction,
                    instruction(dut.if_instruction));
            
            // ID Stage
            if (!dut.stall_id) begin
                $display("  [ID] Instruction: %s", 
                        instruction(dut.pipe_regs.id_instruction));
            end else begin
                $display("  [ID] Stalled");
            end
            
            // EX Stage
            if (!dut.flush_ex) begin
                if (dut.pipe_regs.ex_alu_src_b_sel) begin
                    $display("  [EX] ALU: RS1=0x%h, Imm=0x%h", 
                            dut.ex_rs1_data_fwd, dut.pipe_regs.ex_immediate);
                end else begin
                    $display("  [EX] ALU: RS1=0x%h, RS2=0x%h", 
                            dut.ex_rs1_data_fwd, dut.ex_rs2_data_fwd);
                end
            end else begin
                $display("  [EX] Flushed");
            end
            
            // MEM Stage
            if (dut.pipe_regs.mem_mem_read) begin
                $display("  [MEM] Read: Addr=0x%h → Data=0x%h", 
                        dut.pipe_regs.mem_alu_result, dut.mem_read_data);
            end else if (dut.pipe_regs.mem_mem_write) begin
                $display("  [MEM] Write: Addr=0x%h ← Data=0x%h", 
                        dut.pipe_regs.mem_alu_result, dut.pipe_regs.mem_write_data);
            end
            
            // WB Stage
            if (dut.pipe_regs.wb_reg_write && dut.pipe_regs.wb_rd_addr != 0) begin
                $display("  [WB] Register: x%0d ← 0x%h", 
                        dut.pipe_regs.wb_rd_addr, dut.wb_data);
            end
            
            // Hazard/Control info (condensed into one line when relevant)
            if (dut.branch_taken || dut.stall_if || dut.stall_id || dut.flush_ex) begin
                $display("  [CTRL] Branch=%b Stall_IF=%b Stall_ID=%b Flush_EX=%b",
                        dut.branch_taken, dut.stall_if, dut.stall_id, dut.flush_ex);
            end
            
            $display("==========================================");
        end else begin
            prev_reg_write <= 0;
        end
    end

endmodule