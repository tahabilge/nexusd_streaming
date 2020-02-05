%% Connect to SPTM by using the connect_to_nexus function
clear all; close all

%[inst_1, status] = connect_to_nexus(current_port);
% COM3 is left USB port in XPS, SHOULD BE STRIATAL!
[inst_1, status_1] = connect_to_nexus('COM3');
[inst_2, status_2] = connect_to_nexus('COM5');

%%
% Start sensing
inst_1.startSensing; % this will leave sensing on when data session ends
pause(0.1);
inst_2.startSensing;
pause(0.1);

% WARNING: THE CODE ASSUMES THAT THE DEFAULT STIM GROUP IS B AND
% EXPERIMENTAL STIM GROUP IS D. PROCEED WITH CAUTION!!!

% IT ALSO ASSUMES THAT STRIATAL CONNECTS TO THE RIGHT USB PORT!!!

% Change stim group to D in inst_1
inst_1.setActiveGroup(4);
disp('Stim group changed to Group D')
% Send triggers in succession

inst_1.sendTrigger();
inst_2.sendTrigger();
disp('Triggers sent!')

pause(2);
inst_1.setActiveGroup(2);
disp('Stim group changed to Group B (Original)')
pause(0.1);

%% Disconnect PCS
disconnect_pcs(inst_1); disconnect_pcs(inst_2);
disp('Done!');