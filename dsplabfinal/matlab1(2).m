op1 = readmatrix("op1_Q3_14.txt");
op2 = readmatrix("op2_Q5_12.txt");

v_add = str2double(readlines("verilog_add.txt"));
v_sub = str2double(readlines("verilog_sub.txt"));
v_mul = str2double(readlines("verilog_mul.txt"));

% Find common minimum length
L = min([length(op1), length(op2), length(v_add), length(v_sub), length(v_mul)]);

op1 = op1(1:L);
op2 = op2(1:L);
v_add = v_add(1:L);
v_sub = v_sub(1:L);
v_mul = v_mul(1:L);

% Convert op2 to Q14
op2_q14 = op2 * 4;

% MATLAB outputs
m_add = op1 + op2_q14;
m_sub = op1 - op2_q14;
m_mul = fix((op1 .* op2) / 2^12);

% Scaling to float
scale = 2^14;

m_add_f = m_add / scale;
v_add_f = v_add / scale;

m_sub_f = m_sub / scale;
v_sub_f = v_sub / scale;

m_mul_f = m_mul / scale;
v_mul_f = v_mul / scale;

% Plot first N samples
N = min(240, L);

figure;
plot(m_add_f(1:N), 'o');
hold on;
plot(v_add_f(1:N), '*');

title('Addition Output: MATLAB vs Verilog');
xlabel('Sample Index');
ylabel('Value');
legend('MATLAB','Verilog');
grid on;


figure;
plot(m_sub_f(1:N), 'o');
hold on;
plot(v_sub_f(1:N), '*');

title('Subtraction Output: MATLAB vs Verilog');
xlabel('Sample Index');
ylabel('Value');
legend('MATLAB','Verilog');
grid on;


figure;
plot(m_mul_f(1:N), 'o');
hold on;
plot(v_mul_f(1:N), '*');

title('Multiplication Output: MATLAB vs Verilog');
xlabel('Sample Index');
ylabel('Value');
legend('MATLAB','Verilog');
grid on;

% Table for first 100 samples
M = min(100, L);
Index = (1:M)';

comparison_table = table( ...
    Index, ...
    m_add_f(1:M), v_add_f(1:M), ...
    m_sub_f(1:M), v_sub_f(1:M), ...
    m_mul_f(1:M), v_mul_f(1:M), ...
    'VariableNames', {'Index', ...
    'MATLAB_ADD', 'Verilog_ADD', ...
    'MATLAB_SUB', 'Verilog_SUB', ...
    'MATLAB_MUL', 'Verilog_MUL'} );

disp("Comparison Table (First Samples):");
disp(comparison_table);
