%%% PC+S Data Streaming Script %%%
%%% Written by Taha Bilge. taha.bilge@gmail.com or mbilge@mgh.harvard.edu

%%% This script connects to PC+S via Nexus-D, stream data from it,
%%% visualize the data stream, and save the data to a single file. It also
%%% receives event markers from a DAQ. It can change therapy settings and
%%% switch between stimulation groups (e.g., experimental, original, A, B)
%%% during data acquisition.

%%% This script utilizes various functions. Please check the documentation
%%% provided in individual functions definition for further help.

%% Connect to SPTM by using the connect_to_nexus function
clear all; close all
% Global marker to signal that experiment has started
global experiment_start_marker; experiment_start_marker = false;
global streaming_only; streaming_only = false;

%current_port = find_current_ser_port; % Automatically find the serial port
% CHANGE THIS LINE TO SPECIFY THE USB PORT
%[inst_1, status] = connect_to_nexus(current_port);
%[inst_1, status] = connect_to_nexus('COM5'); % Right hand USB port on XPS
[inst_1, status] = connect_to_nexus('COM3'); % Left hand USB port on XPS

% Specify the default folder
default_folder = cd;
% Start sensing
inst_1.startSensing; % this will leave sensing on when data session ends
%% Folder preparation, data acquisition, visualization, and saving

% Look for DAQ and configure it using the search_config_daq function
[DaqList, DaqIndex, PortIdx] = search_config_daq;

% Prepare some IPG parameters and directories for recording
[dir_name, ipg_1_type, ipg_1_req_stim_status, orig_stim_group, ...
    exp_stim_group, subj_code, visit_code]= prepare_params_dirs_solo;

% Write channel config parameters to a text file
ch_config = write_pcs_config(inst_1, dir_name, 'ipg_1', ...
    ipg_1_type, subj_code, visit_code);

% Go to the default folder. Note that the script moves from folder to
% folder during data acquisition.
cd(default_folder)

% Start data session. Pick a packet first to check the sampling rate.
inst_1.startDataSession(); pause(1)
D = inst_1.getDataPacket(); samp_rate = D.getChSampleRates();
% Sampling Rate for the first channel
samp_rate = samp_rate(1); % assuming both channels have the same SR
% Find the index of active channels. Indices will be used to extract data.
active_chs = find(~cellfun(@isempty, D.getData()));
% number of data points in one package, will be used for plotting
pack_length = (400 * samp_rate) / 1000;
pack_times = linspace(1, 400, pack_length);

% Create UI controls. Check the script to modify UI.
ui_design_solo;

% Back to plotting parameters
double_window_size = 2000;
times_window = linspace(1, double_window_size, double_window_size);

% This is the first subplot
my_ax_1 = subplot('Position', [.05 .2 .85 .70]);
plot_1 = plot(times_window, NaN(1, double_window_size), 'red', ...
    times_window, NaN(1, double_window_size), 'blue');
my_ax_1.YLim = [0, 1100];

% MATLAB - I hate you deeply. Why don't you have any coherency in syntax?
set(my_ax_1.Title, 'String', [ipg_1_type ' Leads']);
set(my_ax_1.YAxis.Label, 'String', 'Voltage (au)');
set(my_ax_1.XAxis.Label, 'String', 'Time (s)');
set(plot_1(1), 'LineWidth', 1.5);
set(plot_1(2), 'LineWidth', 1.5);

leg = legend(plot_1([1 2]), 'Lead 1', 'Lead 2');

step = double_window_size / pack_length + 1; % will be used for modulus

% Anonymous func: circular modulus to avoid zeros in addressing time. Used
% for continuous plotting.
wrap_n = @(x, N) (1 + mod(x-1, N));

% DATA ACQUISITION LOOP
% Initialize num_pack and initiate the data acquisition loop.

% Go to the subject's directory
cd pcs_streaming_data; cd(subj_code); cd(visit_code); cd(fullfile(dir_name));
pack_ix = 1; line_ct = 0; % to keep track of event marker lines

% This loop detects the experiment marker
while true
    drawnow
    if experiment_start_marker || stop_state; break; end
end

while true
    query_daq = false;
    if isempty(status) || stop_state
        break
        %elseif inst.getLastInsResponseCode() == -1
        %    disp('Device Powered off or antenna not in range.Please restart!')
        %    break
    end
    
    if streaming_only == false
        if pack_ix == 2000 / 400 % 2 seconds after (5th package)
            if strcmp(ipg_1_req_stim_status, 'off')
                inst_1.therapyOff
            end
            inst_1.setActiveGroup(orig_stim_group)
            query_daq = true;
        end
    end
    %data_acq_tic = tic;
    D = inst_1.getDataPacket(); % retrieve data from Nexus
    daq_tic = tic;
    % skip the iteration if D cannot be transmitted
    if isempty(D)
        continue
    end
    ipg_1_temp = D.getData();
    ipg_1_temp_ch1 = double(ipg_1_temp{active_chs(1)});
    ipg_1_temp_ch2 = double(ipg_1_temp{active_chs(2)});

    % Receive DAQ trigger
    events_ix = 1;
    events = 0; % reset the variable
    % Don't query DAQ during stim change
    if ~isempty(DaqIndex) && query_daq == true

        while toc(daq_tic) < 0.100 % 100 ms for DAQ stuff if we can afford it :)
            rec_daq = DaqDIn(DaqIndex, PortIdx + 1);
            events(events_ix) = rec_daq(PortIdx + 1);
            events_ix = events_ix + 1;
        end
        orig_events_len = length(events);
        % We want the DAQ array to be of length 20, so we expand the last
        % element of the original array.
        % First, check if array is no longer than 20
        if orig_events_len >= 5
            events = events(1:5);
        else
            events(orig_events_len:5) = events(end);
        end
        % 20 * 4 = 80 (desired length of the array);
        % repeat elements to make the array of length 80
        events = repelem(events, 4);
        events(21:80) = ones(1, 60) * 31; % zero padding (31 is DAQ's null)
%         % Mark where DAQ entries change in rec_daq_arr for visualization
%         event_change_indices = find(diff(events) ~= 0) + 1;
%         % The two if statements below are to catch event changes at the end
%         % of a package.
%         if pack_ix > 2
%             last_event_previous_pack = events(end);
%             if last_event_previous_pack ~= events(1)
%                 event_change_indices = horzcat(event_change_indices, 0);
%             end
%         end
    end

    % Save Files
    % The filenames are simply the time of recording (e.g., 152413312.mat
    % means the file was created at 3:24:13:312 pm).
    current_time = datestr(now, 'HHMMSSFFF');
    if events == 0
        save([current_time '.mat'], 'ipg_1_temp_ch1', 'ipg_1_temp_ch2')
    elseif any(events ~= 0) && logical(exist('orig_events_len', 'var'))
        save([current_time '.mat'], 'ipg_1_temp_ch1', 'ipg_1_temp_ch2', ...
            'events', 'orig_events_len')
    end


    % Visualize data
    % Clear the graph at the end of the cycle and create tick marks
    if wrap_n(pack_ix, step - 1) == 1
        ipg_1_ch1s_window = ones(1, double_window_size) * 530; % 500 ~ flat
        ipg_1_ch2s_window = ones(1, double_window_size) * 530;
        tick_factor = double(floor(pack_ix / (step - 1)));
        my_ax_1.XTickLabel = linspace(tick_factor * double_window_size, ...
            (tick_factor + 1) * double_window_size, 11) / 200;
        if pack_ix ~= 1 && exist('em_lines', 'var')
            delete(em_lines);
        end
    end


    window_start = wrap_n((pack_ix - 1) * pack_length + 1, ...
        double_window_size);
    window_end = wrap_n(pack_ix * pack_length, double_window_size);

    ipg_1_ch1s_window(window_start:window_end) = ipg_1_temp_ch1;
    ipg_1_ch2s_window(window_start:window_end) = ipg_1_temp_ch2;

    set(plot_1(1), 'XData', times_window, 'YData', ipg_1_ch1s_window);
    set(plot_1(2), 'XData', times_window, 'YData', ipg_1_ch2s_window);

%     if exist('event_change_indices', 'var')
%         for line_ix = 1:length(event_change_indices)
%             line_ct = line_ct + 1;
%             em_line_ix = window_start + event_change_indices(line_ix);
%             em_lines(line_ct) = line([em_line_ix em_line_ix], ...
%                 my_ax_1.YLim, 'Color', 'g', 'LineWidth', 1.3, ...
%                 'Parent', my_ax_1);
%         end
%     end

    drawnow
    pause(0.01);

    %status = inst.getNexusStatus();
    pack_ix = pack_ix + 1;
    %disp(toc(data_acq_tic));
end
%% Combine mat files to a single mat file and visualize summary
cd(default_folder)
if pack_ix > 1 % do the above only if there are streamed data
    % Combine mat files into one mat file after the while loop ends.
    [ipg_1_all_ch1, ipg_1_all_ch2] = save_combined_mat_files_solo(inst_1, ...
        dir_name, default_folder, 'ipg_1', samp_rate, subj_code, visit_code, ch_config, ipg_1_type);
    % Draw summary and coherence plots
%     draw_summary_plots_solo(pack_length, samp_rate, ...
%         ipg_1_all_ch1, ipg_1_all_ch2)
end
%% Disconnect PCS
disconnect_pcs(inst_1);
