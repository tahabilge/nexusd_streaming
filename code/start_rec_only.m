function start_rec_only(src, event)
    
    % This function is used in the GUI to switch to experimental settings.
    % 
    % EXPECTS
    % inst: Nexus-D object.
    % req_stim_status: Whether experimenter wants stim on or off.
    % dest: The experimental group's number.
    %  
    % RETURNS
    % None

    global experiment_start_marker % To signal that the experiment started.
    global streaming_only
    experiment_start_marker = true; streaming_only = true;
end