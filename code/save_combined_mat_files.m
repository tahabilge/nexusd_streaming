function [ipg_1_all_ch1, ipg_1_all_ch2, ipg_2_all_ch1, ipg_2_all_ch2] = ...
    save_combined_mat_files(inst_1, inst_2, dir_name, default_folder, ...
    ipg_1_name, ipg_2_name, samp_rate, subj_code, visit_code, ch_config_ipg_1, ...
    ch_config_ipg_2)

    % This function combines and saves the single mat files to a larger  
    % mat file. The mat files include Ch1 and Ch2 data, and event markers
    % if they exist.
    %
    % EXPECTS
    % dir_name: Name of the directory where single mat files are stored.
    % default_folder: Name of the parent directory where scripts reside.
    % ipg_name: The IPG used for the connection (IPG 1 or IPG 2).
    % 
    % RETURNS
    % ipg_1_all_ch1: Combined channel 1 data for IPG 1.
    % ipg_1_all_ch2: Combined channel 2 data for IPG 1.
    % ipg_2_all_ch1: Combined channel 1 data for IPG 2.
    % ipg_2_all_ch2: Combined channel 2 data for IPG 2.

   cd pcs_streaming_data; cd(subj_code); cd(visit_code); cd(fullfile(dir_name))
    % Combine mat files into one mat file after the while loop ends.
    all_mat_files = dir('*.mat');
    ipg_1_all_ch1 = []; ipg_1_all_ch2 = []; 
    ipg_2_all_ch1 = []; ipg_2_all_ch2 = []; 
    all_events = []; all_orig_event_lens = [];
    for i = 1:length(all_mat_files)

        temp_all = load(all_mat_files(i).name());
        ipg_1_all_ch1 = [ipg_1_all_ch1; temp_all.([ipg_1_name '_temp_ch1'])];
        ipg_1_all_ch2 = [ipg_1_all_ch2; temp_all.([ipg_1_name '_temp_ch2'])];
        
        ipg_2_all_ch1 = [ipg_2_all_ch1; temp_all.([ipg_2_name '_temp_ch1'])];
        ipg_2_all_ch2 = [ipg_2_all_ch2; temp_all.([ipg_2_name '_temp_ch2'])];
        
        if isfield(temp_all, 'events') && ...
                isfield(temp_all, 'orig_events_len')
            all_events = [all_events; temp_all.('events')];
            all_orig_event_lens = [all_orig_event_lens; ...
                temp_all.('orig_events_len')];
        end
        %end
    end
    % Convert all_events to an array
    ipg_data = horzcat(ipg_1_all_ch1, ipg_1_all_ch2, ipg_2_all_ch1, ...
        ipg_2_all_ch2)';
    all_events = transpose(all_events); all_events = all_events(:)';
    all_orig_event_lens = all_orig_event_lens';
    % If there is no DAQ, fill the DAQ array with zeroes
    if isempty(all_events)
        all_events = zeros(1, length(ipg_1_all_ch1));
    end
    
    ipg_data = [ipg_data; all_events];
    
    % Recording channels
    ipg_1_ch_config = ch_config_ipg_1.getSenseChannels();
    ipg_1_ch_config_1 = char(ipg_1_ch_config(1).toString);
    ipg_1_lead_1_rec_1 = regexp(ipg_1_ch_config_1, ...
        'minusElectrode=(\d*)', 'tokens');
    ipg_1_lead_1_rec_2 = regexp(ipg_1_ch_config_1, ...
        'plusElectrode=(\d*)', 'tokens');
    S1 = [char(ipg_1_lead_1_rec_1{1}) '-' char(ipg_1_lead_1_rec_2{1})];
    
    ipg_1_ch_config_3 = char(ipg_1_ch_config(3).toString);
    ipg_1_lead_2_rec_1 = regexp(ipg_1_ch_config_3, ...
        'minusElectrode=(\d*)', 'tokens');
    ipg_1_lead_2_rec_2 = regexp(ipg_1_ch_config_3, ...
        'plusElectrode=(\d*)', 'tokens');
    S2 = [char(ipg_1_lead_2_rec_1{1}) '-' char(ipg_1_lead_2_rec_2{1})];

    ipg_2_ch_config = ch_config_ipg_2.getSenseChannels();
    ipg_2_ch_config_1 = char(ipg_2_ch_config(1).toString);
    ipg_2_lead_1_rec_1 = regexp(ipg_2_ch_config_1, ...
        'minusElectrode=(\d*)', 'tokens');
    ipg_2_lead_1_rec_2 = regexp(ipg_2_ch_config_1, ...
        'plusElectrode=(\d*)', 'tokens');
    C1 = [char(ipg_2_lead_1_rec_1{1}) '-' char(ipg_2_lead_1_rec_2{1})];
    
    ipg_2_ch_config_3 = char(ipg_2_ch_config(3).toString);
    ipg_2_lead_2_rec_1 = regexp(ipg_2_ch_config_3, ...
        'minusElectrode=(\d*)', 'tokens');
    ipg_2_lead_2_rec_2 = regexp(ipg_2_ch_config_3, ...
        'plusElectrode=(\d*)', 'tokens');
    C2 = [char(ipg_2_lead_2_rec_1{1}) '-' char(ipg_2_lead_2_rec_2{1})];
    
    row_names = sprintf('S1: %s, S2: %s, C1: %s, C2: %s, DAQ', S1, S2, ...
        C1, C2);
    
    save([dir_name '.mat'], 'ipg_data', 'all_events', ...
        'all_orig_event_lens', 'samp_rate', 'row_names')
    cd(default_folder)
end