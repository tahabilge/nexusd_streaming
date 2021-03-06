function start_experiment(src, event, inst, dest)
    
    % This function is used in the GUI to switch to experimental settings.
    % 
    % EXPECTS
    % inst: Nexus-D object.
    % req_stim_status: Whether experimenter wants stim on or off.
    % dest: The experimental group's number.
    %  
    % RETURNS
    % None
    
    inst.setActiveGroup(dest);
    pause(0.01);
    inst.therapyOn
    pause(0.01);
    
end