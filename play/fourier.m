function [runGizmo, gaborCount, algOutput] = fourier(gaborCount, NUM_CHANNELS, algOutput, Fs, runGizmo, allData, sliceVals, dataCount, FREQ_INCR)
    %fourier  Preforms fourier transformation on data
    
    %% Constants
    WINDOW_SIZE = 300;
    SLICE_COUNT = 9;
    SLICE_STEP = 5;
    
    FIGURE_Y_MAX_LIM = 1000;
    FIGURE_Y_MAX_MID_LIM = FIGURE_Y_MAX_LIM / 2;
    FIGURE_Y_MIN_LIM = -1 * FIGURE_Y_MAX_LIM;
    FIGURE_Y_MIN_MID_LIM = FIGURE_Y_MIN_LIM / 2;
    
    % https://stackoverflow.com/questions/31325491/how-to-design-a-zero-phase-bandpass-filter-for-1-to-20-hz-in-matlab
    % Changed to be a 1-50 bandpass
    B_PASS = fir1(400, [1, 50] / (Fs / 2));
    A_PASS = 1;
    
    
    %% Preform fourier transformation
    % Returns runGizmo as boolean or -1 if no transformation
    if (gaborCount >= WINDOW_SIZE)
                displayData = filtfilt(B_PASS, A_PASS, allData);

                gaborSlice = displayData(dataCount - WINDOW_SIZE:dataCount, :);

                fhat = fft(gaborSlice, [], 1);
                PSD = fhat.*conj(fhat) / WINDOW_SIZE;

                for k = SLICE_STEP:SLICE_STEP:(SLICE_STEP * SLICE_COUNT)
                    s_ind = floor(k / FREQ_INCR);
                    e_ind = floor((k + SLICE_STEP) / FREQ_INCR) + 1;

                    sliceVals(k / SLICE_STEP, :) = mean(PSD(s_ind:e_ind, :));
                end

                [~, minInds] = min(sliceVals, [], 1);
                [~, maxInds] = max(sliceVals, [], 1);

                allChannels = maxInds > minInds;

                runGizmo = allChannels(1) | allChannels(2) | allChannels(3) | allChannels(4);


                if runGizmo
                    
                    algOutput(dataCount - WINDOW_SIZE:dataCount, :) = FIGURE_Y_MAX_MID_LIM;
                else
                    
                    algOutput(dataCount - WINDOW_SIZE:dataCount, :) = FIGURE_Y_MIN_MID_LIM;
                end
                
                gaborCount = 0;
            else 
                gaborCount = gaborCount + 1;
                runGizmo = -1;

    end
end


% func[OUT] = funcName(IN)