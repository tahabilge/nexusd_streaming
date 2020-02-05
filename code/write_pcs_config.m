function ch_config = write_pcs_config(inst, dir_name, ipg, ipg_type, subj_code, visit_code)

    % This function writes the current PC+S configuration to a text file.
    % 
    % EXPECTS
    % inst: The Nexus-D object on which all operations are run.
    % dir_name: Name of the directory where data are stored.
    % ipg: Name of the IPG (e.g., IPG_1 or IPG_2)
    % ipg_type: Striatal or Cortical.
    % 
    % RETURNS
    % ch_config

    cd pcs_streaming_data; cd(subj_code); cd(visit_code);
    % Write channel config parameters to a text file
    ch_config = inst.getSenseChannelParameters();
    if ~isempty(ch_config)
        temp_config = ch_config.getSenseChannels();
        cd(fullfile(dir_name))
        fileID = fopen([ipg '_and_session_info.txt'], 'w');
        for i = 1:length(temp_config)
            channel_info = char(temp_config(i));
            % the \r character is necessary for MS Notepad
            fprintf(fileID, 'Ch %s: %s\r\n', num2str(i), ...
                channel_info(18:end));
        end
        fprintf(fileID, 'IPG Type: %s\r\n', ipg_type);
        fprintf(fileID, 'Session Date: %s\r\n', datetime('now'));
        fclose(fileID);
        cd ..
    end
    cd ../..
end