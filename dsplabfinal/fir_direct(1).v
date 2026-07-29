module fir_direct (
    input wire clk,
    input wire reset,
    input wire [15:0] x_in,
    output reg [31:0] y_out
);

reg [15:0] coeffs [0:99];
reg [15:0] delay_line [0:99];
integer i, j, status,coeff_file;
reg signed [39:0] acc;

initial begin
    coeff_file = $fopen("filter_coeffs.txt","r");
    if (coeff_file == 0) begin
        $display("ERROR: filter_coeffs.txt not found - run MATLAB first");
        for (i=0; i<100; i=i+1) begin
            coeffs[i] = 16'd0;
            delay_line[i] = 16'd0;
        end
    end else begin
        for (i=0; i<100; i=i+1) begin
            if (!$feof(coeff_file)) begin
                status = $fscanf(coeff_file,"%d", coeffs[i]);
            end else begin
                coeffs[i] = 16'd0;
            end
            delay_line[i] = 16'd0;
        end
        $fclose(coeff_file);
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 100; i = i + 1) begin
            delay_line[i] <= 16'd0;
        end
        y_out <= 32'd0;
    end else begin
        acc = $signed(x_in) * $signed(coeffs[0]);
        for (j = 0; j < 99; j = j + 1) begin
            acc = acc + $signed(delay_line[j]) * $signed(coeffs[j+1]);
        end
        y_out <= acc[31:0];

        for (i = 99; i > 0; i = i - 1) begin
            delay_line[i] <= delay_line[i-1];
        end
        delay_line[0] <= x_in;
    end
end

endmodule
