function current_port = find_current_ser_port

    % This function finds the serial port to be used in connection. 
    % However, it only works if there is one serial port device 
    % connected. If there is more than one device, specify the serial 
    % ports manually.
    %
    % EXPECTS
    % None
    %
    % RETURNS
    % inst: The Nexus Instrument object on which all operations will be run.
    % status: The status of inst.

    % Check which serial ports are available
    serialInfo = instrhwinfo('serial');
    % The first serial port is probably the right port.
    current_port = serialInfo.SerialPorts(1);
end