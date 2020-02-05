function [DaqList, DaqIndex, PortIdx] = search_config_daq

    % This function checkes whether there is a DAQ connected to the PC.
    % 
    % EXPECTS
    % None
    %  
    % RETURNS
    % DaqList: An array with available DAQs.
    % DaqIndex: The index of the first DAQ connected to the system.
    % PortIdx: The input DAQ port.

    % DAQ Business
    disp('Searching for DAQ...');
    DaqList = DaqDeviceIndex();

    if isempty(DaqList)
        disp('No DAQ detected in system!');
        DaqIndex = [];
    else
        disp(['DAQ detected! Index number: ', num2str(DaqList(1))]);
        DaqIndex = DaqList(1);
    end

    % Configure ports. Set to input.
    if ~isempty(DaqList)
        PortIdx = 0; % Port A
        DaqDConfigPort(DaqIndex, 0, 1); 
    else
        PortIdx = [];
    end
end