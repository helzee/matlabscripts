function output = gabor_transform(matrix, window_size, overlap, displayFFT)
%GABOR_TRANSFORM Creates a sliding window of the matrix based on size
%n
%   Creates a square sliding window of the matrix, creates n sized matrixes

displayFFT = logical(displayFFT);

output = zeros(size(matrix));

offset = 1;

% Sampling frequency for my case frequency is 300 because 300 data points per second
Fs = 300;

dt = 1/Fs;

% Creates the vector of frequencies that is the x axis. Goes from lowest
% frequency 0 to highest frequency which is the size of the window
freq = 1/(dt*window_size)*(0:window_size);

w = width(matrix);

Length = 1:floor(window_size/2);

for index = 1:length(matrix) / (window_size - overlap)
    slice = matrix(offset:offset + window_size, :);   

    for jindex = 1:w
        sslice = slice(:, jindex);
        fhat = fft(sslice);

        % Compute the power spectrum (power per frequency)
        % FFT creates fhat. Fhat is a matrix of complex values that have a
        % magnitude and a phase. The magnitude tells you the occurences of
        % the frequency(sine and cosine). Phase tells you if the magnitude
        % is more sine or cosine. This equation does the equivalent of
        % magnitude of fhat squared.
        PSD = fhat.*conj(fhat)/window_size;

        graphPSD = PSD;

        if displayFFT
            figure(index)
            t = stackedplot(slice);
            t.Title = sprintf('Figure %d unfiltered data', index);
            t.XLabel = 'Data Points (300 samples per second)';
            t.DisplayLabels = "Microvolts";

            figure (100 + index)
            plot(freq(Length), graphPSD(Length));
            title(sprintf('Figure %d Fast Fourier Transform', index))
            xlabel('Power Spectrum (Hz)')
            ylabel('Frequency (Microvolts)')


            % the first bit of the fourier transform has noise at the
            % beginning that we can discard when we want to use the data
            % to make desisions.
            graphPSD(1:30,:) = 0;
    
            figure (1000 + index)
            plot(freq(Length), graphPSD(Length));
            title(sprintf('Figure %d Fast Fourier Transform (low band pass filtered)', index))
            xlabel('Power Spectrum (Hz)')
            ylabel('Frequency (Microvolts)')
        end

        PSD(1:175,:) = 0;

        avg = trapz(PSD);
        output(offset + window_size,jindex) = avg;
    end
    
    offset = offset + (window_size - overlap);

    if offset + window_size > length(matrix)
        break
    end
end

end