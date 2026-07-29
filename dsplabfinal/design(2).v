module fixed_point_unit(
    input  signed [17:0] op1_q314,
    input  signed [17:0] op2_q512,
    output signed [19:0] add_out_q14,
    output signed [19:0] sub_out_q14,
    output signed [23:0] mul_out_q14
);

    wire signed [17:0] op2_q14;
    wire signed [35:0] mul_raw;

    assign op2_q14 = op2_q512 <<< 2;

    assign add_out_q14 = op1_q314 + op2_q14;
    assign sub_out_q14 = op1_q314 - op2_q14;

    assign mul_raw = op1_q314 * op2_q512;
    assign mul_out_q14 = mul_raw >>> 12;

endmodule
