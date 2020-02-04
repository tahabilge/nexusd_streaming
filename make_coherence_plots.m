function make_coherence_plots(pack_length, samp_rate, ipg_1_all_ch1, ...
    ipg_1_all_ch2, ipg_2_all_ch1, ipg_2_all_ch2)

    % This function draws the coherence of the collected data.
    %
    % EXPECTS
    %
    % pack_length: How many data points each data package has.
    % samp_rate: Sampling rate of IPG.
    % ipg_1_all_ch1: Combined IPG 1 channel 1 data.
    % ipg_1_all_ch2: Combined IPG 1 channel 2 data.
    % ipg_2_all_ch1: Combined IPG 2 channel 1 data.
    % ipg_2_all_ch2: Combined IPG 2 channel 2 data.
    %
    % RETURNS
    % None
    
    %time_step = 400 / pack_length;
    %concat_times = (0:time_step:(length(ipg_1_all_ch1) - 1) * time_step) ./ 1000;
    
    all_data{1} = ipg_1_all_ch1; all_data{2} = ipg_1_all_ch2;
    all_data{3} = ipg_2_all_ch1; all_data{4} = ipg_2_all_ch2;
    
    ch_names{1} = 'Striatal Ch 1'; ch_names{2} = 'Striatal Ch 2';
    ch_names{3} = 'Cortical Ch 1'; ch_names{4} = 'Cortical Ch 2';
    
    combins = sort(combnk(1:4, 2), 2); % All combinations with two elements
    % Calculate coherence
    figure('Units', 'normalized', 'Position', [0 0 1 1]); % Fullscreen
    
    for ix = 1:length(combins)
        [cxy, f] = mscohere(all_data{combins(ix, 1)}(501:end), ...
            all_data{combins(ix, 2)}(501:end), ...
            hamming(256), [], [], double(samp_rate));
        subplot(2, 3, ix);
        plot(f, cxy, 'LineWidth', 1.5)
        xlabel('Frequency (Hz)'); ylabel('Coherence');
        pl_tit = sprintf('%s and %s', ...
            char(ch_names(combins(ix, 1))), char(ch_names(combins(ix, 2))));
        title(pl_tit)
    end
    suptitle('Coherence between Striatal and Cortical Channels')
end