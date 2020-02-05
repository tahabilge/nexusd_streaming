function disconnect_pcs(inst)

    % This function disconnects the Nexus-D API from MATLAB.
    %
    % EXPECTS
    % None
    %
    % RETURNS
    % None

    % Stop the data session. I'm not sure if this is necessary.
    inst.stopDataSession();

    inst.setNexusConfiguration(10, 2);
    inst.disconnect;
    pause(3)
    inst.disconnect;

end