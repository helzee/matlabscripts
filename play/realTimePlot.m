function [plotCounter] = realTimePlot(plotCounter, algOutput, displayData, timeLog, dataCount)
%realTimePlot 

% Constants
FIGURE_SIZE = 900;
FIGURE_WRITE_DELAY = 36;
DATAPOINTS_PER_SEC = 300;

% Wait a specified number of cycles before plotting the data to increase performance
if plotCounter >= FIGURE_WRITE_DELAY 
    if dataCount <= FIGURE_SIZE
        smallSlice = 1:dataCount;

        graphLog = [displayData(smallSlice, :), algOutput(smallSlice, :)];
        graphTime = timeLog(smallSlice);
    else
        bigSlice = dataCount - FIGURE_SIZE;

        graphLog = [displayData(bigSlice:dataCount, :), algOutput(bigSlice:dataCount)];
        graphTime = timeLog(bigSlice:dataCount);
    end

    set(gca,'NextPlot','replacechildren');

    plot(graphTime, graphLog);

    %legend show
    xlim([graphTime(1) - 1 / DATAPOINTS_PER_SEC, graphTime(end) + 1 / DATAPOINTS_PER_SEC])

    drawnow;

    plotCounter = 0;
else
    plotCounter = plotCounter + 1;
end

end