
fs = 10000;          % Sampling frequency (Hz)
fc = 1000;           % Cutoff frequency (Hz)
N = 100;             % Number of taps
frequencies = [950, 1100, 2000];  % Test frequencies
signal_names = {'950Hz', '1100Hz', '2000Hz'};

t = 0:1/fs:0.1;  % 0.1 seconds duration
t = t(1:1000);   % Take first 1000 samples

% Normalized cutoff frequency for fir1()
wn = fc/(fs/2);

% Use fir1() with a Hamming window to obtain 100-tap lowpass filter
% N is the number of taps, so the fir1 order is N-1
b_float = fir1(N-1, wn, hamming(N));

% Normalize to ensure unity gain at DC
b_float = b_float / sum(b_float);

% Convert to fixed-point Q(2,14)
b_fixed = round(b_float * 2^14);

% Save filter coefficients
fid = fopen('filter_coeffs.txt', 'w');
for i = 1:length(b_fixed)
    fprintf(fid, '%d\n', b_fixed(i));
end
fclose(fid);

fprintf('Filter Order: %d, Taps: %d\n', N-1, N);
fprintf('Filter coefficients saved\n\n');

% Store signals for all methods
x_float_cell = cell(1, length(frequencies));
x_fixed_cell = cell(1, length(frequencies));

for idx = 1:length(frequencies)
    f = frequencies(idx);
    name = signal_names{idx};
    
    % Generate sine wave
    x_float = sin(2*pi*f*t);
    x_fixed = round(x_float * 2^14);
    
    % Store
    x_float_cell{idx} = x_float;
    x_fixed_cell{idx} = x_fixed;
    
    % Save input signal
    filename = sprintf('signal_%s.txt', name);
    fid = fopen(filename, 'w');
    for i = 1:length(x_fixed)
        fprintf(fid, '%d\n', x_fixed(i));
    end
    fclose(fid);
    
    fprintf('Signal %s generated\n', name);
end

fprintf('\n========== METHOD 1: DIRECT FORM FIR ==========\n');

% Initialize output storage
y1_fixed_cell = cell(1, length(frequencies));

for idx = 1:length(frequencies)
    name = signal_names{idx};
    x_fixed = x_fixed_cell{idx};
    
    % Direct Form implementation
    % y[n] = Σ h[k] * x[n-k] for k=0 to N-1
    
    % Initialize delay line (holds previous input samples)
    delay_line = zeros(1, N);
    y_fixed = zeros(1, length(x_fixed));
    
    for n = 1:length(x_fixed)
        % Shift delay line and insert new sample
        for k = N:-1:2
            delay_line(k) = delay_line(k-1);
        end
        delay_line(1) = x_fixed(n);
        
        % Compute output: multiply-accumulate
        acc = 0;
        for k = 1:N
            acc = acc + delay_line(k) * b_fixed(k);
        end
        y_fixed(n) = acc;
    end
    
    y1_fixed_cell{idx} = y_fixed;
    
    % Save output
    filename = sprintf('matlab_output_direct_%s.txt', name);
    fid = fopen(filename, 'w');
    for i = 1:length(y_fixed)
        fprintf(fid, '%d\n', y_fixed(i));
    end
    fclose(fid);
    
    fprintf('Direct Form output for %s computed\n', name);
end

fprintf('\n========== METHOD 2: OPTIMIZED FORM FIR (USING SYMMETRIC COEFFICIENTS) ==========\n');

% Optimized form using coefficient symmetry
% For linear phase FIR filters with symmetric coefficients:
% y[n] = h[0]*(x[n] + x[n-(N-1)]) + h[1]*(x[n-1] + x[n-(N-2)]) + ...

y2_fixed_cell = cell(1, length(frequencies));

for idx = 1:length(frequencies)
    name = signal_names{idx};
    x_fixed = x_fixed_cell{idx};
    
    % Initialize delay line
    delay_line = zeros(1, N);
    y_fixed = zeros(1, length(x_fixed));
    
    for n = 1:length(x_fixed)
        % Shift delay line and insert new sample
        for k = N:-1:2
            delay_line(k) = delay_line(k-1);
        end
        delay_line(1) = x_fixed(n);
        
        % Optimized MAC using coefficient symmetry
        % Only need to compute half the multiplications
        acc = 0;
        for k = 1:N/2
            % For symmetric coefficients: h(k) = h(N-k+1)
            % Multiply coefficient with sum of symmetric samples
            acc = acc + b_fixed(k) * (delay_line(k) + delay_line(N-k+1));
        end
        
        y_fixed(n) = acc;
    end
    
    y2_fixed_cell{idx} = y_fixed;
    
    % Save output
    filename = sprintf('matlab_output_optimized_%s.txt', name);
    fid = fopen(filename, 'w');
    for i = 1:length(y_fixed)
        fprintf(fid, '%d\n', y_fixed(i));
    end
    fclose(fid);
    
    fprintf('Optimized Form output for %s computed\n', name);
end

fprintf('\n========== METHOD 3: GENVAR-STYLE FIR (PARALLEL MAC) ==========\n');

% Genvar-style implementation with parallel MAC units
y3_fixed_cell = cell(1, length(frequencies));

for idx = 1:length(frequencies)
    name = signal_names{idx};
    x_fixed = x_fixed_cell{idx};
    
    % Initialize delay line
    delay_line = zeros(1, N);
    y_fixed = zeros(1, length(x_fixed));
    
    for n = 1:length(x_fixed)
        % Shift delay line (parallel assignment)
        delay_line = [x_fixed(n), delay_line(1:end-1)];
        
        % Parallel MAC operations - each tap multiplies independently
        mac_results = zeros(1, N);
        for k = 1:N
            mac_results(k) = delay_line(k) * b_fixed(k);
        end
        
        % Cascade addition (simulating the MAC block chain)
        acc = 0;
        for k = 1:N
            acc = acc + mac_results(k);
        end
        y_fixed(n) = acc;
    end
    
    y3_fixed_cell{idx} = y_fixed;
    
    % Save output
    filename = sprintf('matlab_output_genvar_%s.txt', name);
    fid = fopen(filename, 'w');
    for i = 1:length(y_fixed)
        fprintf(fid, '%d\n', y_fixed(i));
    end
    fclose(fid);
    
    fprintf('Genvar-style output for %s computed\n', name);
end

% Verification plot
figure('Name', 'Detailed Method Comparison', 'Position', [100, 100, 1400, 900]);

% Take a small section to show detail
samples_to_plot = 150;

for idx = 1:length(frequencies)
    f = frequencies(idx);
    
    % Convert to float for plotting
    x_float = x_fixed_cell{idx} / 2^14;
    y1_float = y1_fixed_cell{idx} / 2^14;
    y2_float = y2_fixed_cell{idx} / 2^14;
    y3_float = y3_fixed_cell{idx} / 2^14;
    
    % Plot all three methods (they should overlap perfectly)
    subplot(3,3,3*idx-2);
    plot(t(1:samples_to_plot)*1000, x_float(1:samples_to_plot), 'b-', 'LineWidth', 1.5);
    title(sprintf('%d Hz - Input Signal', f));
    xlabel('Time (ms)'); ylabel('Amplitude'); grid on;
    
    subplot(3,3,3*idx-1);
    plot(t(1:samples_to_plot)*1000, y1_float(1:samples_to_plot), 'r-', 'LineWidth', 2);
    hold on;
    plot(t(1:samples_to_plot)*1000, y2_float(1:samples_to_plot), 'g--', 'LineWidth', 1.5);
    plot(t(1:samples_to_plot)*1000, y3_float(1:samples_to_plot), 'b:', 'LineWidth', 1.5);
    title(sprintf('%d Hz - All Methods', f));
    xlabel('Time (ms)'); ylabel('Amplitude');
    legend('Direct', 'Optimized', 'Genvar', 'Location', 'best');
    grid on;
    
    % Plot differences (should be zero)
    subplot(3,3,3*idx);
    plot(t(1:samples_to_plot)*1000, (y1_float(1:samples_to_plot) - y2_float(1:samples_to_plot))*2^14, 'g-', 'LineWidth', 1);
    hold on;
    plot(t(1:samples_to_plot)*1000, (y1_float(1:samples_to_plot) - y3_float(1:samples_to_plot))*2^14, 'r--', 'LineWidth', 1);
    title(sprintf('%d Hz - Differences (x2^14)', f));
    xlabel('Time (ms)'); ylabel('Difference (LSBs)');
    legend('Direct-Optimized', 'Direct-Genvar', 'Location', 'best');
    grid on;
    ylim([-1 1]);  % Should be 0 if identical
end
sgtitle('FIR Filter: All Three Methods Produce Identical Results (Differences = 0)');
saveas(gcf, 'three_methods_verified.png');