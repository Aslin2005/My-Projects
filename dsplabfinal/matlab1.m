clc;
clear;

FRAC = 30;
N = 6;
LUT_SIZE = 2^N;
scale = 2^FRAC;

d_min = 0.5;
d_max = 1;

% ---------------------------
% Generate LUT
% ---------------------------
lut = zeros(LUT_SIZE,1);

for i = 0:LUT_SIZE-1
    d_i = d_min + (i + 0.5)*(d_max - d_min)/LUT_SIZE;
    lut(i+1) = round((1/d_i) * scale);
end

% ---------------------------
% Test Cases
% ---------------------------
A_array = [15 12 19 8 27];
D_array = [23 37 101 59 83];

for k = 1:length(A_array)

    A = A_array(k);
    D = D_array(k);

    % -------- Normalize --------
    msb_pos = floor(log2(D));
    shift = (FRAC - 1) - msb_pos;

    d_norm = bitshift(D, shift);

    % Convert to real normalized value
    d_real = double(d_norm)/scale;

    % -------- LUT Index --------
    index = floor((d_real - 0.5)/0.5 * LUT_SIZE);
    if index >= LUT_SIZE
        index = LUT_SIZE-1;
    end

    x = lut(index+1);

    % -------- Newton Iteration 1 --------
    temp = bitshift(d_norm * x, -FRAC);
    x = bitshift(x * (2*scale - temp), -FRAC);

    % -------- Newton Iteration 2 --------
    temp = bitshift(d_norm * x, -FRAC);
    x = bitshift(x * (2*scale - temp), -FRAC);

     % -------- Newton Iteration 3 --------
    temp = bitshift(d_norm * x, -FRAC);
    x = bitshift(x * (2*scale - temp), -FRAC);

    % -------- Newton Iteration 4 --------
    temp = bitshift(d_norm * x, -FRAC);
    x = bitshift(x * (2*scale - temp), -FRAC);

     % -------- Newton Iteration 5 --------
    temp = bitshift(d_norm * x, -FRAC);
    x = bitshift(x * (2*scale - temp), -FRAC);

    % -------- Final Multiply --------
    result_fixed = bitshift(A * x, -(FRAC - shift));
    result_real = result_fixed / scale;

    fprintf('\nTest: %d / %d\n', A, D);
    fprintf('Result   : %.12f\n', result_real);
    fprintf('Expected : %.12f\n', A/D);
    fprintf('Error    : %e\n', abs(result_real - A/D));

end