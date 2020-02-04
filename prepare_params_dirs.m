function [dir_name, ipg_1_type, ipg_2_type, ipg_1_req_stim_status, ...
    ipg_2_req_stim_status, orig_stim_group, exp_stim_group, subj_code, visit_code] = ...
    prepare_params_dirs

    % This function creates directories with the info supplied by another
    % function, namely "collect_session_info".
    %
    % EXPECTS
    % None
    %
    % RETURNS
    % dir_name: The name of the directory created for a given session.

    % Check if the data directory exists. If not make the directory.
    if ~exist('pcs_streaming_data', 'dir')
        mkdir('pcs_streaming_data');
    end
    cd('pcs_streaming_data\');

    % Collect the info via a message box (see the function def below).
    [subj_code, visit_code, visit_day, session_task, ...
        ipg_1_type, ipg_2_type, ...
        ipg_1_req_stim_status, ipg_2_req_stim_status, orig_stim_group,...
        exp_stim_group] = collect_session_info;
    
    if ~exist(subj_code, 'dir')
        mkdir(subj_code)
    end
    cd(subj_code);
    
    if ~exist(subj_code, 'dir')
        mkdir(visit_code)
    end
    cd(visit_code);

    % For the current info, make a directory for the first trial if it 
    % doesn't exist yet.
    current_info = [subj_code '_eegv' visit_code '_' visit_day '_'];
    current_info = [current_info session_task '_dbs'];
    dir_name = [current_info '_try1'];
    if ~exist(dir_name, 'dir')
        mkdir(dir_name);
    % The next trial
    elseif exist(dir_name, 'dir')
        % make a new directory with the name trial n + 1
        folders = dir([current_info '*try*']);
        trial_nums = [];
        for i = 1:size(folders, 1)
            temp_num = folders(i).name(length(current_info) + 2 + ...
                length('try'):end);
            trial_nums = [trial_nums ' ' temp_num];
        end
        max_trial_num = max(str2num(trial_nums));
        dir_name = [current_info '_try' num2str(max_trial_num + 1)];
        mkdir(dir_name)
    end
    cd ../..
end

function [subj_code, visit_code, visit_day, session_task, ipg_1_type, ...
    ipg_2_type, ipg_1_req_stim_status, ipg_2_req_stim_status, ...
    orig_stim_group, exp_stim_group] = ...
    collect_session_info

    % This function creates a dialog box to inquire about details of the 
    % PC+S data streaming session. The collected information is then 
    % saved.
    %
    % EXPECTS
    % None
    %
    % RETURNS
    % subj_code: pcs0X or pcspX
    % visit_code: 0a(pre-surgery baseline), 0b(post-surgery baseline), or 1-6
    % visit_day: Day1 or Day2 (two-day visits)
    % session_task: The task to be run. FE(hbt, acq, ext, rcl);
    %               MSIT(msiton, msitoff); 
    %               Resting State(closedrest, openrest).

    prompt = {'Subject Code: (e.g., pcs01)', 'Visit Code: (e.g., 0a)', ...
        'Day: (e.g., 1)', 'Task: (e.g., msiton)', ...
        'IPG 1 Type: (Striatal or Cortical)', 'IPG 2 Type: (Striatal or Cortical)', ... 
        'IPG 1 Req Stim: (On or Off)', 'IPG 2 Req Stim: (On or Off)', ...
        'Original Stim Group: (A=1 to D=4)', 'Experimental Stim Group: '};

    dlg_title = 'PC+S Info';
    num_lines = 1;
    defaultans = {'test','0z', '1', 'notask', 'Striatal', 'Cortical', ...
        'On' , 'Off', '1', '4'};
    answer = inputdlg(prompt, dlg_title, num_lines, defaultans);

    % Extract the information from the answer cell. Clear spaces.
    subj_code = answer{1}; subj_code = subj_code(~isspace(subj_code));
    visit_code = answer{2}; visit_code = visit_code(~isspace(visit_code));
    visit_day = ['day' answer{3}]; visit_day = ...
        visit_day(~isspace(visit_day));
    session_task = answer{4}; session_task = ...
        session_task(~isspace(session_task));
    ipg_1_type = answer{5}; ipg_1_type = ipg_1_type(~isspace(ipg_1_type));
    ipg_2_type = answer{6}; ipg_2_type = ipg_2_type(~isspace(ipg_2_type));
    ipg_1_req_stim_status = answer{7}; ipg_1_req_stim_status = ...
        lower(ipg_1_req_stim_status);
    ipg_2_req_stim_status = answer{8}; ipg_2_req_stim_status = ...
        lower(ipg_2_req_stim_status);
    orig_stim_group = str2double(answer{9});
    exp_stim_group = str2double(answer{10});
 
end