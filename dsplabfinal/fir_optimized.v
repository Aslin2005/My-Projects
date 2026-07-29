module fir_optimized (
    input wire clk,
    input wire reset,
    input wire signed [15:0] x_in,
    output reg signed [31:0] y_out
);

parameter N = 100;
parameter HALF = N/2;

reg signed [15:0] coeffs [0:N-1];
reg signed [15:0] delay_line [0:N-1];
integer i, status, coeff_file;
reg signed [39:0] acc;

// Load coefficients
initial begin
    coeff_file = $fopen("filter_coeffs.txt","r");
    if (coeff_file == 0) begin
        $display("ERROR: filter_coeffs.txt not found");
        for (i=0;i<N;i=i+1) begin
            coeffs[i] = 16'd0;
            delay_line[i] = 16'd0;
        end
    end
    else begin
        for (i=0;i<N;i=i+1) begin
            if (!$feof(coeff_file))
                status = $fscanf(coeff_file,"%d",coeffs[i]);
            else
                coeffs[i] = 16'd0;

            delay_line[i] = 16'd0;
        end
        $fclose(coeff_file);
    end
end


always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i=0;i<N;i=i+1)
            delay_line[i] <= 16'd0;
        y_out <= 32'd0;
    end
    else begin

        acc = 0;

        // First symmetric pair (x[n] and x[n-99])
        acc = acc + coeffs[0] * (x_in + delay_line[98]);

        // Remaining symmetric pairs
        for (i=1;i<HALF;i=i+1)
            acc = acc + coeffs[i] * (delay_line[i-1] + delay_line[98-i]);

        y_out <= acc[31:0];

        // Shift delay line
        for (i=N-1;i>0;i=i-1)
            delay_line[i] <= delay_line[i-1];

        delay_line[0] <= x_in;

    end
end

endmodule