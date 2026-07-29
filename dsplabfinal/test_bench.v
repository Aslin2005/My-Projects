`timescale 1ns/1ps

module tb_fixed_point_unit;

    integer f1, f2;
    integer fadd, fsub, fmul;
    integer i;
    integer N;
    integer r1, r2;

    reg  signed [17:0] op1;
    reg  signed [17:0] op2;

    wire signed [19:0] add_out;
    wire signed [19:0] sub_out;
    wire signed [23:0] mul_out;

    fixed_point_unit DUT(
        .op1_q314(op1),
        .op2_q512(op2),
        .add_out_q14(add_out),
        .sub_out_q14(sub_out),
        .mul_out_q14(mul_out)
    );

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_fixed_point_unit);

        N = 48000;

        f1 = $fopen("op1_Q3_14.txt", "r");
        f2 = $fopen("op2_Q5_12.txt", "r");

        fadd = $fopen("verilog_add.txt", "w");
        fsub = $fopen("verilog_sub.txt", "w");
        fmul = $fopen("verilog_mul.txt", "w");

        for (i = 0; i < N; i = i + 1) begin
            r1 = $fscanf(f1, "%d\n", op1);
            r2 = $fscanf(f2, "%d\n", op2);

            #1;

            $fwrite(fadd, "%d\n", add_out);
            $fwrite(fsub, "%d\n", sub_out);
            $fwrite(fmul, "%d\n", mul_out);
        end

        $fclose(f1);
        $fclose(f2);

        $fclose(fadd);
        $fclose(fsub);
        $fclose(fmul);

        $finish;
    end

endmodule
