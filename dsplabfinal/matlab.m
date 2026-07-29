f  = 1000;
Fs = 48000;
A  = 2;

t = 0:1/Fs:1-1/Fs;
x = A*sin(2*pi*f*t);

T = 1/f;
N = round(5*T*Fs);

figure;
stem(t(1:N), x(1:N), 'filled');
xlabel('Time (s)');
ylabel('Amplitude');
title('Original Sampled Signal (5 Cycles)');
grid on;
op1_Q3_14 = fix(x * 2^14);
op2_Q5_12 = fix(x * 2^12);

writematrix(op1_Q3_14', "op1_Q3_14.txt");
writematrix(op2_Q5_12', "op2_Q5_12.txt");
writematrix(x', "original_signal.txt");