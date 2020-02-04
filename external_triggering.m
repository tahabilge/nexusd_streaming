%% Connect to SPTM by using the connect_to_nexus function
clear all; close all

%[inst_1, status] = connect_to_nexus(current_port);
[inst_1, status_1] = connect_to_nexus('COM3');
[inst_2, status_2] = connect_to_nexus('COM5');

%%
% Start sensing
inst_1.startSensing; % this will leave sensing on when data session ends
pause(0.1);
inst_2.startSensing;
pause(0.1);

% Send triggers in succession

inst_1.sendTrigger();
inst_2.sendTrigger();

%% Disconnect PCS
disconnect_pcs(inst_1); disconnect_pcs(inst_2);
disp('TRIGGERS SENT SUCCESSFULLY!');