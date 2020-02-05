function switch_groups(source, event, inst)

    % This function is used in GUI to switch groups.
    % 
    % EXPECTS
    % inst: The Nexus-D connection object
    %
    % RETURNS
    % None
    
    val = source.Value; % Picks the group number
    
    inst.setActiveGroup(val);
end