function [fig] = createEvent()
%createEvent Summary of this function goes here
%   % An event will be either flashing lights or a sound

%fig = figure;
fig = figure('WindowState', 'maximized', 'Color', 'black'); % Full-screen figure
rectangle('FaceColor', [0 0 0]) % [0, 0, 0] is black

%{

%% Used for the action function. Switch between the functions to use different variables
color_array = ["r", "g", "b", "c", "m", "y"];
[~, colors_size] = size(colors);

% Also used for the action function. This crazy loop can be simplified
notes = {'C' 'G' 'A' 'F'}; %notes which will be used
freq = [261.60 391.99 440.00 349.23]; %frequencies of notes above
melody = {'C' 'G' 'A' 'F' 'C' 'G' 'A' 'F'}; %four chords played twice
sounds = [];

%For Loop
for k = 1:numel(melody)
    note = 0:0.00025:1.0; % Note duration (which can be edited for length)
    sounds = [sounds sin(2 * pi * freq(strcmp(notes, melody{k})) * note)];
end

[~, sounds_size] = size(sounds);

activity_state = activity_states.none;
%}
end