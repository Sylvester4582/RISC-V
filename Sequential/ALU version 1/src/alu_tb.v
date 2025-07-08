// Testbench v3(not bash)
module alu_tb();

    reg [2:0] funct3;
    reg [6:0] funct7;

    reg [63:0] rs1;
    reg [63:0] rs2;
    wire [63:0] rd;
    // test variables
    reg [63:0] expected;
    integer file, scan_file, i;
    integer passed_tests, total_tests;
    reg [8*128-1:0] line;

    alu dut(
        .funct3(funct3),
        .funct7(funct7),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd)
    );

    initial begin
        
        passed_tests = 0;
        total_tests = 0;
        
        file = $fopen("data/testcases.txt", "r");
        if (file == 0) begin
            $display("404");
            $finish;
        end

        i = 0;
        while (!$feof(file)) begin
            
            scan_file = $fgets(line, file);
            if (line[0] == "/" || line[0] == "\n" || line == 0) begin
                
            end
            else begin
                
                scan_file = $sscanf(line, "%b %b %h %h %h", 
                    funct3, funct7, rs1, rs2, expected);
                
                if (scan_file == 5) begin
                    total_tests = total_tests + 1;
                    #10;
                    
                    if (rd !== expected) begin
                        $display("Test %0d FAILED", total_tests);
                        $display("Inputs : funct3=%b, funct7=%b, rs1=%h, rs2=%h", funct3, funct7, rs1, rs2);
                        $display("Expected : %h, Got: %h\n", expected, rd);
                    end 
                    else begin
                        passed_tests = passed_tests + 1;
                        $display("Test %0d PASSED!", total_tests);
                    end
                end
            end
        end

        $fclose(file);
        $display("\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("Total tests: %0d", total_tests);
        $display("Passed: %0d", passed_tests);
        $display("Failed: %0d", total_tests - passed_tests);
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
        $display("All tests completed, Hell yea");
        $finish;
    end

endmodule