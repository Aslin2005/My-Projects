
fs = 10000;
OUTPUT_SCALE = 2^28;
PLOT_TIME_MS = 15;

signal_names = {'950Hz', '1100Hz', '2000Hz'};
methods = {'direct', 'optimized', 'genvar'};
method_titles = {'Direct', 'Optimized', 'Genvar'};

% 9 subplots: MATLAB vs Verilog (3 signals x 3 methods) - Only 15ms
fig = figure('Name','MATLAB vs Verilog FIR Outputs (15ms)','Position',[50,50,1600,1000],'PaperPositionMode','auto');
for s = 1:3
    sig = signal_names{s};
    for m = 1:3
        meth = methods{m};
        matlab_file = sprintf('matlab_output_%s_%s.txt', meth, sig);
        verilog_file = sprintf('verilog_%s_%s.txt', meth, sig);

        subplot(3, 3, (s-1)*3 + m);
        
        % Load MATLAB data
        if exist(matlab_file, 'file')
            y_m = load(matlab_file);
            y_m_f = y_m / OUTPUT_SCALE;
        else
            text(0.5, 0.5, sprintf('MATLAB file missing:\n%s', matlab_file), ...
                'HorizontalAlignment', 'center', 'FontSize', 10);
            title(sprintf('%s - %s', sig, method_titles{m}), 'FontSize', 11);
            xlabel('Time (ms)','FontSize',10);
            ylabel('Amplitude','FontSize',10);
            grid on; set(gca,'FontSize',10);
            continue;
        end

        % Calculate number of samples for 15ms
        samples_15ms = round(PLOT_TIME_MS * fs / 1000);
        
        if exist(verilog_file,'file')
            y_v = load(verilog_file);
            
            % Use minimum of available lengths
            L = min([length(y_m), length(y_v), samples_15ms]);
            
            y_v_plot = y_v(1:L)/OUTPUT_SCALE;
            y_m_plot = y_m_f(1:L);
            t_plot = (0:L-1)/fs * 1000;  % Time in ms
            
            max_diff = max(abs(y_m(1:L) - y_v(1:L)));
            
            plot(t_plot, y_m_plot, 'b-', 'LineWidth', 1.2);
            hold on;
            plot(t_plot, y_v_plot, 'r--', 'LineWidth', 0.9);
            title(sprintf('%s - %s (|diff|=%d)', sig, method_titles{m}, max_diff), 'FontSize', 11);
            legend('MATLAB','Verilog','Location','best','FontSize',9);
            
        else
            % Only MATLAB data available
            L = min(length(y_m), samples_15ms);
            t_plot = (0:L-1)/fs * 1000;  % Time in ms
            plot(t_plot, y_m_f(1:L), 'b-', 'LineWidth', 1.2);
            title(sprintf('%s - %s (No Verilog file)', sig, method_titles{m}), 'FontSize', 11);
        end
        
        % Set x-axis limits to exactly 15ms
        xlim([0 PLOT_TIME_MS]);
        xlabel('Time (ms)','FontSize',10);
        ylabel('Amplitude','FontSize',10);
        grid on; set(gca,'FontSize',10);
    end
end
sgtitle(sprintf('MATLAB vs Verilog FIR: 3 Signals x 3 Methods (%d ms view)', PLOT_TIME_MS), 'FontSize', 14, 'FontWeight', 'bold');
print(fig, 'matlab_verilog_9subplots_15ms', '-dpng', '-r150');