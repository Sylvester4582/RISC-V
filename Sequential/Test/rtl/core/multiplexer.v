module multiplexer #(
    parameter WIDTH = 64,           // Data width
    parameter NUM_INPUTS = 2        // Number of inputs (must be 2^SELECT_BITS)
) (
    input wire [WIDTH-1:0] in0,    // First input
    input wire [WIDTH-1:0] in1,    // Second input
    input wire [$clog2(NUM_INPUTS)-1:0] select,      // Select lines
    output reg [WIDTH-1:0] out                       // Output
);

    always @(*) begin
        case (select)
            1'b0: out = in0;
            1'b1: out = in1;
            default: out = {WIDTH{1'bx}};
        endcase
    end

endmodule

// 2-to-1 multiplexer
module mux2 #(
    parameter WIDTH = 64
) (
    input wire [WIDTH-1:0] in0,
    input wire [WIDTH-1:0] in1,
    input wire select,
    output wire [WIDTH-1:0] out
);

    multiplexer #(
        .WIDTH(WIDTH),
        .NUM_INPUTS(2)
    ) mux (
        .in0(in0),
        .in1(in1),
        .select(select),
        .out(out)
    );

endmodule 