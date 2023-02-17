function []=main(commander_ip, commander_port, dsi_ip, dsi_port)

close all;


commanderClient = tcpclient(commander_ip, commander_port);


%% Settings
runEvents = true;
saveFiles = true;
showPlots = false;

%% Initialize the TCP/IP
t = tcpip(dsi_ip, dsi_port);
fclose(t); %just in case it was open from a previous iteration
fopen(t); %opens the TCPIP connection

% Plotting
if (showPlots)
    newcolors = [0.83 0.14 0.14
                 1.00 0.54 0.00
                 0.47 0.25 0.80
                 0.25 0.80 0.54
                 0.00 0.00 1.00];
    
    colororder(newcolors);
end 

% Don't change this unless wearable sensing changes their packet structure
HEADER_START = [64, 65, 66, 67, 68]; % All DSI packet headers begin with '@ABCD', corresponding to these ASCII codes.

if (saveFiles)
    fileName = '../play/data/Test/test0.csv';
    textFile = writefile(fileName);
end

%% Customizable Constants
MAX_PACKETS_DROPPED = 15000;

WINDOW_SIZE = 300;
SLICE_COUNT = 9;
DATABUFFER_SIZE = 1201;
NUM_CHANNELS = 4;
Fs = 300; % Device collects 300 samples/sec
dt = 1/Fs;
FREQ_INCR = 1 / (dt * WINDOW_SIZE);

gaborCount = 0;
dataCount = 0;
plotCounter = 0;
packetDropCounter = 0;

% Preallocate memory to avoid repeated reaalocation in upcoming loop
% Initialize timeLog and plotCounter for real time plotting
allData = zeros(DATABUFFER_SIZE, NUM_CHANNELS);
displayData = zeros(DATABUFFER_SIZE, NUM_CHANNELS);
timeLog = zeros(DATABUFFER_SIZE, 1);
algOutput = zeros(DATABUFFER_SIZE, 1);
sliceVals = zeros(SLICE_COUNT, NUM_CHANNELS);

runGizmo = 0;


notDone = 1;
%%while notDone
while true
    %% Termination clause
    if t.Bytesavailable < 12                        %if there's not even enough data available to read the header
        packetDropCounter = packetDropCounter + 1;  %take a step towards terminating the whole thing

        if packetDropCounter == MAX_PACKETS_DROPPED %and if 1500 steps go by without any new data,
            notDone = 0;                            %terminate the loop.
        end

        %disp('no bytes available') % Load bearing disp(). If removed increase the pause time
        pause(0.05)
        continue
    else  %meaning, unless there's data available.
        packetDropCounter = 0;
    end

    %% Read the packet
    packet_info = uint8(fread(t, 12))'; % Loads the first 12 bytes of the first packet, which should be the header
    data = [packet_info, uint8(fread(t, double(typecast(fliplr(packet_info(7:8)), 'uint16'))))']; % Loads the full packet, based on the header
    lengthdata = length(data);

    % Checks if the packet contains the header
    if all(ismember(HEADER_START, data)) 
        % This determines whether it's an event or sensor packet.
        packetType = data(6);          

        %% Event Packet.  This includes the greeting packet
        if packetType == 5
            disp("event packet!")
        end

        %% EEG sensor packet
        if (packetType == 1)
            Timestamp = swapbytes(typecast(data(13:16),'single'));
            EEGdata = swapbytes(typecast(data(24:lengthdata),'single'));

            EEGdata(8:end) = [];

            % We only use:
            % Channel 2: F4-LE
            % Channel 4: C4-LE
            % Channel 6: P3-LE
            % Channel 7: P4-LE

            % Disgard EEG channels that are unused in the algorithm
            EEGdata(5) = [];
            EEGdata(3) = [];
            EEGdata(1) = [];

            %% Add EEG data to buffer
            if dataCount <= DATABUFFER_SIZE
                dataCount = dataCount + 1;

                allData(dataCount,:) = EEGdata;
                displayData(dataCount,:) = EEGdata;

                timeLog(dataCount,:) = Timestamp;

                algOutput(dataCount,:) = 0;
            else
                allData = circshift(allData, -1);
                allData(dataCount,:) = EEGdata;

                displayData = circshift(displayData, -1);
                displayData(dataCount,:) = EEGdata;

                timeLog = circshift(timeLog, -1);
                timeLog(end) = Timestamp;

                algOutput = circshift(algOutput, -1);
                algOutput(end) = 0;
            end % Buffer
            
            %% Perform fourier transform on data
            [isClench, gaborCount, algOutput] = fourier(gaborCount, NUM_CHANNELS, algOutput, Fs, runGizmo, allData, sliceVals, dataCount, FREQ_INCR);
            %send isClench to GizmoCommander
            if (isClench > -1)
                fprintf("jaw clenched = %d\n", isClench);
                writeline(commanderClient, string(isClench));
          
            end
            %%send client isClentch in 8 bit int
            
            
        end % If packet type == 1
        
        %% Plot data in realtime
        if (showPlots)
            [plotCounter] = realTimePlot(plotCounter, algOutput, displayData, timeLog, dataCount);
        end
    end % If packet contains header
end % While not done




end