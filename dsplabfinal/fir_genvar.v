
// One FFB DUT block (combinational):  b_out = b_in + x_k * h_k
module ffb_stage #(
    parameter DATA_WIDTH  = 16,
    parameter COEFF_WIDTH = 16,
    parameter PROD_WIDTH  = 32,
    parameter SUM_WIDTH   = 40
)(
    input  wire signed [DATA_WIDTH-1:0]  x_k,
    input  wire signed [COEFF_WIDTH-1:0] h_k,
    input  wire signed [SUM_WIDTH-1:0]   b_in,
    output wire signed [SUM_WIDTH-1:0]   b_out
);

    wire signed [PROD_WIDTH-1:0] prod;
    wire signed [SUM_WIDTH-1:0]  prod_ext;

    assign prod     = $signed(x_k) * $signed(h_k);
    assign prod_ext = {{(SUM_WIDTH-PROD_WIDTH){prod[PROD_WIDTH-1]}}, prod};
    assign b_out    = $signed(b_in) + prod_ext;

endmodule


module fir_genvar #(
    parameter TAPS        = 100,
    parameter DATA_WIDTH  = 16,
    parameter COEFF_WIDTH = 16,
    parameter ACC_WIDTH   = 32
)(
    input  wire                          clk,
    input  wire                          reset,
    input  wire signed [DATA_WIDTH-1:0]  x_in,
    output wire signed [ACC_WIDTH-1:0]   y_out
);

    localparam PROD_WIDTH = DATA_WIDTH + COEFF_WIDTH;
    localparam SUM_WIDTH  = 40;

    reg  signed [COEFF_WIDTH-1:0] coeffs [0:TAPS-1];
    reg  signed [DATA_WIDTH-1:0]  x_pipe [0:TAPS-1];
    wire signed [SUM_WIDTH-1:0]   b      [0:TAPS];

    integer i, status,coeff_file;
    initial begin
        coeff_file = $fopen("filter_coeffs.txt","r");
        if (coeff_file == 0) begin
            $display("ERROR: filter_coeffs.txt not found - run MATLAB first");
            for (i = 0; i < TAPS; i = i + 1)
                coeffs[i] = '0;
        end else begin
            for (i = 0; i < TAPS; i = i + 1) begin
                if (!$feof(coeff_file))
                    status = $fscanf(coeff_file,"%d", coeffs[i]);
                else
                    coeffs[i] = '0;
            end
            $fclose(coeff_file);
        end
    end

    // Sample delay chain
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < TAPS; i = i + 1)
                x_pipe[i] <= '0;
        end else begin
            for (i = TAPS-1; i > 0; i = i - 1)
                x_pipe[i] <= x_pipe[i-1];
            x_pipe[0] <= x_in;
        end
    end

    assign b[0] = '0;

    genvar k;
    generate
        for (k = 0; k < TAPS; k = k + 1) begin : BCHAIN
            ffb_stage #(
                .DATA_WIDTH (DATA_WIDTH),
                .COEFF_WIDTH(COEFF_WIDTH),
                .PROD_WIDTH (PROD_WIDTH),
                .SUM_WIDTH  (SUM_WIDTH)
            ) dut_k (
                .x_k  (x_pipe[k]),
                .h_k  (coeffs[k]),
                .b_in (b[k]),
                .b_out(b[k+1])
            );
        end
    endgenerate

    assign y_out = b[TAPS][ACC_WIDTH-1:0];

endmodule