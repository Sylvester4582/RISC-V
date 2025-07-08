// Testbench v3(not bash)
module alu_tb;

    // Inputs
    reg [2:0] funct3;
    reg [6:0] funct7;

    reg [63:0] rs1;
    reg [63:0] rs2;
    
    // Outputs
    wire [63:0] rd;
    
    // Test status
    integer errors;

    alu dut(
        .funct3(funct3),
        .funct7(funct7),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd)
    );

    // Test task
    task check_result;
        input [63:0] expected;
        input [64*8:1] op_name;
    begin
        if (rd !== expected) begin
            $display("ERROR: %s failed. Got %h, expected %h", op_name, rd, expected);
            errors = errors + 1;
        end else begin
            $display("PASS: %s. Result = %h", op_name, rd);
        end
    end
    endtask

    // Test stimulus
    initial begin
        // Initialize
        errors = 0;
        funct7 = 7'b0000000;
        
        // Test ADD
        funct3 = 3'b000;
        rs1 = 64'h5;
        rs2 = 64'h3;
        #10 check_result(64'h8, "ADD     ");
        
        // Test SUB
        funct7 = 7'b0100000;
        #10 check_result(64'h2, "SUB     ");
        
        // Test AND
        funct3 = 3'b111;
        funct7 = 7'b0000000;
        rs1 = 64'hF;
        rs2 = 64'h3;
        #10 check_result(64'h3, "AND     ");
        
        // Test OR
        funct3 = 3'b110;
        #10 check_result(64'hF, "OR      ");
        
        // Test XOR
        funct3 = 3'b100;
        #10 check_result(64'hC, "XOR     ");
        
        // Test SLT (signed)
        funct3 = 3'b010;
        rs1 = 64'hFFFFFFFFFFFFFFFF;  // -1
        rs2 = 64'h0000000000000001;  // 1
        #10 check_result(64'h1, "SLT     ");
        
        // Test SLTU (unsigned)
        funct3 = 3'b011;
        #10 check_result(64'h0, "SLTU    ");
        
        // Test SLL
        funct3 = 3'b001;
        rs1 = 64'h1;
        rs2 = 64'h3;
        #10 check_result(64'h8, "SLL     ");
        
        // Test SRL
        funct3 = 3'b101;
        funct7 = 7'b0000000;
        rs1 = 64'h8;
        rs2 = 64'h2;
        #10 check_result(64'h2, "SRL     ");
        
        // Test SRA
        funct7 = 7'b0100000;
        rs1 = 64'hFFFFFFFFFFFFFFFF;  // -1
        rs2 = 64'h1;
        #10 check_result(64'hFFFFFFFFFFFFFFFF, "SRA     ");
        
        // Report results
        $display("\n=== Test Summary ===");
        $display("Total Errors: %0d", errors);
        if (errors == 0)
            $display("All tests passed!");
        else
            $display("Some tests failed!");
            
        $finish;
    end
    
    // Optional: Generate VCD file
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
    end

endmodule