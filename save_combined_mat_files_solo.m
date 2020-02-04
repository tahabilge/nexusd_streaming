function [ipg_1_all_ch1, ipg_1_all_ch2] = ...
    save_combined_mat_files_solo(inst_1, dir_name, default_folder, ipg_name, ...
    samp_rate, subj_code, visit_code, ch_config, ipg_type)

    % This function combines and saves the single mat files to a larger  
    % mat file. The mat files include Ch1 and Ch2 data, and event markers
    % if they exist.
    %
    % EXPECTS
    % dir_name: Name of the directory where single mat files are stored.
    % default_folder: Name of the parent directory where scripts reside.
    % ipg_name: The IPG used for the connection (ipg_1).
    % ipg_type: The type of IPG (Cortical or Striatal)
    % 
    % RETURNS
    % all_ch1: Combined channel 1 data.
    % all_ch2: Combined channel 2 data.
    
    cd pcs_streaming_data; cd(subj_code); cd(visit_code); cd(fullfile(dir_name))
    % Combine mat files into one mat file after the while loop ends.
    all_mat_files = dir('*.mat');
    ipg_1_all_ch1 = []; ipg_1_all_ch2 = []; 
    all_events = []; all_orig_event_lens = [];
    for i = 1:length(all_mat_files)
        % Get rid of DAQ files
        %if ~contains(all_mat_files(i).name(), '_DAQ')
        temp_all = load(all_mat_files(i).name());
        ipg_1_all_ch1 = [ipg_1_all_ch1; temp_all.([ipg_name '_temp_ch1'])];
        ipg_1_all_ch2 = [ipg_1_all_ch2; temp_all.([ipg_name '_temp_ch2'])];
        if isfield(temp_all, 'events') && ...
                isfield(temp_all, 'orig_events_len')
            all_events = [all_events; temp_all.('events')];
            all_orig_event_lens = [all_orig_event_lens; ...
                temp_all.('orig_events_len')];
        end
        %end
    end

    % Convert all_events to an array
    all_events = transpose(all_events); all_events = all_events(:)';
    all_orig_event_lens = all_orig_event_lens';
    ipg_data = horzcat(ipg_1_all_ch1, ipg_1_all_ch2)';
    % If there is no DAQ, fill the DAQ array with zeroes
    if isempty(all_events)
        all_events = zeros(1, length(ipg_1_all_ch1));
    end
    ipg_data = [ipg_data; all_events];
    
    % Recording channels
    ch_config = ch_config.getSenseChannels();
    ch_config_1 = ch_config(1);
    ipg_1_lead_1_rec_1 = ch_config_1.getPlusElectrode;
    ipg_1_lead_1_rec_2 = ch_config_1.getMinusElectrode;
    if ipg_1_lead_1_rec_1 >= 8
        side = 'R';
        ipg_1_lead_1_rec_1 = ipg_1_lead_1_rec_1 - 8;
        ipg_1_lead_1_rec_2 = ipg_1_lead_1_rec_2 - 8;
    else
        side = 'L';
    end
    if strcmpi(ipg_type, 'striatal')
        type = 'S';
    else
        type = 'C';
    end
    S1 = [type, side, int2str(ipg_1_lead_1_rec_1), '-', int2str(ipg_1_lead_1_rec_2)];
    
    ch_config_1 = ch_config(3);
    ipg_1_lead_1_rec_1 = ch_config_1.getPlusElectrode;
    ipg_1_lead_1_rec_2 = ch_config_1.getMinusElectrode;
    if ipg_1_lead_1_rec_1 >= 8
        side = 'R';
        ipg_1_lead_1_rec_1 = ipg_1_lead_1_rec_1 - 8;
        ipg_1_lead_1_rec_2 = ipg_1_lead_1_rec_2 - 8;
    else
        side = 'L';
    end
    S2 = [type, side, int2str(ipg_1_lead_1_rec_1), '-', int2str(ipg_1_lead_1_rec_2)];
    
    ch_names = sprintf('%s, %s, DAQ', S1, S2);
    
    % convert to millivolts
%     ref_voltage = 2000;
%     adc_range = 2e10;
%     c1_factor = ref_voltage / (ch_config(1).getGain() * adc_range);
%     ipg_data(1, :) = ipg_data(1, :) * c1_factor;
%     c2_factor = ref_voltage / (ch_config(3).getGain() * adc_range);
%     ipg_data(2, :) = ipg_data(2, :) * c2_factor;
    
    save([dir_name '.mat'], 'ipg_data', 'all_orig_event_lens', ...
        'samp_rate', 'ch_names')
    cd(default_folder)
end