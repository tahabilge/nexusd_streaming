% Create a figure handle for dynamic visualization of incoming data.
fg = figure('Units', 'normalized', 'Position', [0 0 1 1]); % Fullscreen

% Define two panels. The first panel is the parent for all push buttons
panel_1 = uipanel(fg, 'Units', 'normalized', 'Position',...
    [.905 .68 .09 .12]);
ipg_1_text = uicontrol(fg, 'Style','text', 'String',...
    'IPG 1: ', 'Units', 'normalized','Position', [.905 .83 .09 .02], ...
    'FontWeight', 'bold', 'FontSize', 10);
panel_2 = uipanel(fg, 'Units', 'normalized', 'Position',...
    [.905 .426 .09 .249]);

% Define the push buttons. Thanks, Matt, for the tips.
rec_only_but = uicontrol(panel_2, 'Style', 'PushButton', 'String',...
    'Start WITHOUT Stim Sync', 'Callback', {@start_rec_only},...
    'Units', 'normalized', 'Position', [0 .771 1 0.238],...
    'BackgroundColor', 'black', 'ForegroundColor', 'green');
start_exp_but = uicontrol(panel_2, 'Style', 'PushButton', 'String',...
    'Start WITH Stim Sync', 'Callback', {@start_experiment, inst_1, ...
    exp_stim_group},'Units', 'normalized', 'Position', [0 .52 1 .238],...
    'BackgroundColor', 'black', 'ForegroundColor', 'green');
artifact_but = uicontrol(panel_2, 'Style', 'PushButton', 'String',...
    'Send Artifact', 'Callback', {@inject_artifact, inst_1, ...
    exp_stim_group},'Units', 'normalized', 'Position', [0 .28 1 .238],...
    'BackgroundColor', 'black', 'ForegroundColor', 'green');
stop_but = uicontrol(panel_2, 'Style', 'PushButton',...
    'String', 'STOP!', 'Callback', 'stop_state = 1',...
    'Units', 'normalized', 'Position', [0 .033 1 .238], ...
    'BackgroundColor', 'black', 'ForegroundColor', 'red');
stop_state = 0;

% Panel 1 UI Controls (For IPG 1)
stim_on_but_1 = uicontrol(panel_1, 'Style', 'PushButton', 'String',...
    'Stim ON', 'Callback', {@turn_stim_on, inst_1},...
    'Units', 'normalized', 'Position', [0 .8 1 .2],...
    'BackgroundColor', 'red');

stim_off_but_1 = uicontrol(panel_1, 'Style', 'PushButton', 'String',...
    'Stim OFF', 'Callback', {@turn_stim_off, inst_1},...
    'Units', 'normalized', 'Position', [0 .58 1 .2],...
    'BackgroundColor', 'green');

group_text_1 = uicontrol(panel_1, 'Style','text', 'String',...
    'Switch to: ', 'Units', 'normalized','Position', [0 .44 1 .12], ...
    'FontWeight', 'bold');

groups_popup_1 = uicontrol(panel_1, 'Style', 'popup',...
    'String', {'Group A', 'Group B', 'Group C', 'Group D'},...
    'Callback', {@switch_groups, inst_1}, 'Units', 'normalized',...
    'Position', [0 .2 1 .08]);