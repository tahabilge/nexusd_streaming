function [inst, status] = connect_to_nexus(current_port)

    % This function loads the Nexus-D API if it's not already in the 
    % workspace,and establishes a serial port connection with it.
    %
    % EXPECTS
    % current_port: The serial port that will be used for connection.
    %
    % RETURNS
    % inst: Nexus Instrument object on which all operations will be run
    % status: The status of inst.

    % Load the java packages if the object inst does not exist.
    if isempty(javaclasspath('-dynamic'))
        javaaddpath('Nexus-D API/NRP1088-36869/jssc.jar')
        javaaddpath('Nexus-D API/NRP1088-36869/nexus.jar')
    end

    % Create a Nexus Instrument Object
    inst = mdt.neuro.nexus.NexusInstrument;

    % Establish connection
    ser = mdt.neuro.nexus.SerialConnection(current_port);

    % Check if the SPTM is already connected, try to connect if it's not
    is_connected = 'NOT_CONNECTED';
    ix = 1;
    % The # of maxium connection attempts is 5
    while (~strcmp(is_connected, 'SUCCESS'))  && ix < 5
        if ix == 1
            disp('Establishing connection to IPG');
        end
        disp(['Attempt: ' num2str(ix)])
        inst.connect(ser); % Setup a serial port connection to the Nexus-D System
        status = inst.getNexusStatus();
        is_connected = inst.toString;
        is_connected = char(is_connected);
        % Pick the connection status from the sentence
        is_connected = is_connected(strfind(is_connected, 'nexusReponse') + ...
            length('nexusReponseCode') + 1:(end - 1));
        WaitSecs(5);
        ix = ix + 1;
    end
    disp(is_connected);

    % Check the status of the device. The status object will be used as the
    % streaming loop starter

    inst.setNexusConfiguration(30, 15); % Set to max timeouts
end