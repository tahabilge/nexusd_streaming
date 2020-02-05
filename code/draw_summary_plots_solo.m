function draw_summary_plots_solo(pack_length, samp_rate, all_ch1, all_ch2)

    % This function draws the coherence and summary plots of the
    % collected data.
    %
    % EXPECTS
    %
    % pack_length: How many data points each data package has.
    % samp_rate: Sampling rate of IPG.
    % all_ch1: Combined channel 1 data.
    % all_ch2: Combined channel 2 data.
    %
    % RETURNS
    % None
    
    time_step = 400 / pack_length;
    concat_times = (0:time_step:(length(all_ch1) - 1) * time_step) ./ 1000;
    figure(2)
    plot(concat_times, all_ch1, 'r', 'DisplayName', ...
        'Lead 1', 'LineWidth', 1.5)
    xlabel('Time (s)'); ylabel('Voltage (au)');
    xlim([0 max(concat_times)]); ylim([0 1100]);
    hold on
    plot(concat_times, all_ch2, 'b', 'DisplayName', ...
        'Lead 2', 'LineWidth', 1.5)
    legend('show')
    title('Raw Combined Data')
    hold off

    % Calculate coherence
    [cxy, f] = mscohere(all_ch1(501:end), all_ch2(501:end), ...
        hamming(256), [], [], double(samp_rate));
    figure(3)
    plot(f, cxy, 'LineWidth', 1.5)
    xlabel('Frequency (Hz)'); ylabel('Coherence');
    title('Coherence between DBS Leads (Shaved Data)')

end