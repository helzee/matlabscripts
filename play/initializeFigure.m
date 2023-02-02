function [allData, displayData, timeLog, algOutput] = initializeFigure(algOutput)
%initializeFigure Summary of this function goes here

% Initialize timeLog and plotCounter for real time plotting
allData = zeros(DATABUFFER_SIZE, NUM_CHANNELS);
displayData = zeros(DATABUFFER_SIZE, NUM_CHANNELS);
timeLog = zeros(DATABUFFER_SIZE, 1);
algOutput = zeros(DATABUFFER_SIZE, 1);

%% Figure Initialization

set(0, 'DefaultLegendAutoUpdate', 'off')

title('Realtime EEG Processing','HandleVisibility','off');
ylabel('Microvolts','HandleVisibility','off');
xlabel('Data Points (300 samples per second)','HandleVisibility','off');

%legend('F4-LE', 'C4-LE', 'P3-LE', 'p4-LE', 'Algorithm Output', 'Location', 'northwest', 'AutoUpdate', 'off');

hold on

ylim([FIGURE_Y_MIN_LIM, FIGURE_Y_MAX_LIM])

end

% https://www.mathworks.com/matlabcentral/answers/338733-how-to-stop-legend-from-adding-data1-data2-when-additional-data-is-plotted