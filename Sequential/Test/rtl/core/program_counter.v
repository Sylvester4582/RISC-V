module program_counter (
    input wire clk,
    input wire rst,
    input wire branch,
    input wire [63:0] branch_target,
    output reg [63:0] pc
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 64'h0000000000000000;
        end else begin
            if (branch)
                pc <= branch_target;
            else
                pc <= pc + 4;
        end
    end

endmodule