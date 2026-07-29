`timescale 1ns / 1ps

module fixed_div_comb (
    input  wire [31:0] numerator,
    input  wire [31:0] denominator,
    output reg  [31:0] result
);

    parameter FRAC = 30;
    parameter N = 6;
    parameter LUT_SIZE = 64;

    localparam [31:0] TWO = 32'd2 << FRAC;

    reg [31:0] d_norm;
    reg signed [6:0] shift;

    reg [31:0] x0;
    reg [31:0] term1, x1;
    reg [31:0] term2, x2;
    reg [31:0] term3, x3;
    reg [31:0] term4, x4;
    reg [31:0] term5, x5;

    reg [63:0] mult_temp;

    reg [31:0] LUT [0:LUT_SIZE-1];
    reg [5:0] index;
    reg [31:0] d_shifted;

    integer i;
    real d_real;

    // LUT generation (simulation safe)
    initial begin
        for (i = 0; i < LUT_SIZE; i = i + 1) begin
            d_real = 0.5 + (i + 0.5)*(0.5/LUT_SIZE);
            LUT[i] = $rtoi((1.0/d_real) * (2.0**FRAC));
        end
    end

    always @(*) begin

        // 1. Find MSB (KEEP YOUR ORIGINAL LOGIC)
        shift = 0;
        for (i = 0; i < 32; i = i + 1) begin
            if (denominator[i])
                shift = (FRAC - 1) - i;
        end

        d_norm = denominator << shift;

        // 2. LUT Initial Guess (NEW PART)

        d_shifted = d_norm - (1 << (FRAC-1));
        index = d_shifted >> (FRAC - N);

        if (index >= LUT_SIZE)
            index = LUT_SIZE - 1;

        x0 = LUT[index];

        // -------- Newton Iterations (UNCHANGED) --------

        // Iteration 1
        mult_temp = d_norm * x0;
        term1 = mult_temp >> FRAC;
        mult_temp = x0 * (TWO - term1);
        x1 = mult_temp >> FRAC;

        // Iteration 2
        mult_temp = d_norm * x1;
        term2 = mult_temp >> FRAC;
        mult_temp = x1 * (TWO - term2);
        x2 = mult_temp >> FRAC;

        // Iteration 3
        mult_temp = d_norm * x2;
        term3 = mult_temp >> FRAC;
        mult_temp = x2 * (TWO - term3);
        x3 = mult_temp >> FRAC;

        // Iteration 4
        mult_temp = d_norm * x3;
        term4 = mult_temp >> FRAC;
        mult_temp = x3 * (TWO - term4);
        x4 = mult_temp >> FRAC;

        // Iteration 5
        mult_temp = d_norm * x4;
        term5 = mult_temp >> FRAC;
        mult_temp = x4 * (TWO - term5);
        x5 = mult_temp >> FRAC;

        // Final scaling (KEEP YOUR ORIGINAL)
        mult_temp = numerator * x5;
        result = mult_temp >> (FRAC - shift);

    end

endmodule