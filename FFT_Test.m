micSampFreq = 8800; %FFT MaxFreq = micSampFreq/2
recObj = audiorecorder(micSampFreq, 16, 1);

samplesPerChunk = 2^13;

freqresolution = micSampFreq / samplesPerChunk
chunkLength = samplesPerChunk/micSampFreq
time_1 = linspace(0,chunkLength,samplesPerChunk);


for i = 1:1
    recordblocking(recObj, chunkLength); 

    y = getaudiodata(recObj);
    
    NFFT = 2^nextpow2(samplesPerChunk*4); % Next power of 2 from length of y
    Y = fft(y,NFFT)/samplesPerChunk;
    f = micSampFreq/2*linspace(0,1,NFFT/2+1);
    
    f(3)-f(2)
    
    [~,I] = max(abs(Y));
    fprintf('Maximum occurs at %d Hz.\n',f(I));
    
    %Plot time signal
    figure(1)
    plot(time_1',y)
    axis([0 chunkLength -.3 .3])
         
    
    % Plot single-sided amplitude spectrum.
    figure(2)
    plot(f,2*abs(Y(1:NFFT/2+1)))
    title('Single-Sided Amplitude Spectrum of y(t)')
    xlabel('Frequency (Hz)')
    ylabel('|Y(f)|')
    axis([10^1 4500 0 .02])

end

