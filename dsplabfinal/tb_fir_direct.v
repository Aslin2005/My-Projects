`timescale 1ns / 1ps

module tb_fir_direct_all();

reg clk;
reg reset;
reg [15:0] x_in;
wire [31:0] y_out;

fir_direct dut (
    .clk(clk),
    .reset(reset),
    .x_in(x_in),
    .y_out(y_out)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

reg [15:0] test_data [0:999];
integer i, f, file_in, file_out, status;
reg [1023:0] file_name_in, file_name_out;

initial begin
    for (f = 0; f < 3; f = f + 1) begin
        case (f)
            0: begin
                file_name_in  = "signal_950Hz.txt";
                file_name_out = "verilog_direct_950Hz.txt";
            end
            1: begin
                file_name_in  = "signal_1100Hz.txt";
                file_name_out = "verilog_direct_1100Hz.txt";
            end
            2: begin
                file_name_in  = "signal_2000Hz.txt";
                file_name_out = "verilog_direct_2000Hz.txt";
            end
        endcase

        file_in = $fopen(file_name_in,"r");
        if (file_in == 0) begin
            $display("ERROR: %s not found - run MATLAB first", file_name_in);
            for (i=0; i<1000; i=i+1) test_data[i] = 16'd0;
        end else begin
            for (i=0; i<1000; i=i+1) begin
                if (!$feof(file_in)) begin
                    status = $fscanf(file_in,"%d", test_data[i]);
                end else begin
                    test_data[i] = 16'd0;
                end
            end
            $fclose(file_in);
        end

        $display("Testing %s ...", file_name_in);
        file_out = $fopen(file_name_out,"w");
        if (file_out == 0) begin
            $display("ERROR: cannot open %s for write", file_name_out);
        end else begin
            x_in = 16'd0;
            reset = 1;
            repeat(3) @(posedge clk);
            reset = 0;
            repeat(2) @(posedge clk);

            for (i = 0; i < 1000; i = i + 1) begin
                x_in = test_data[i];
                @(posedge clk);
                #1;
                $fwrite(file_out, "%0d\n", $signed(y_out));
            end
            $fclose(file_out);
        end
        $display("Completed %s - output saved to %s", file_name_in, file_name_out);
        #50;
    end

    $display("All Direct Form simulations complete");
    $finish;
end

endmodule
