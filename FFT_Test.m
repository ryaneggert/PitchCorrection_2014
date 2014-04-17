micSampFreq = 88000; %FFT MaxFreq = micSampFreq/2
recObj = audiorecorder(micSampFreq, 16, 1);

samplesPerChunk = 2^20;

freqresolution = micSampFreq / samplesPerChunk
chunkLength = samplesPerChunk/micSampFreq;
time_1 = linspace(0,chunkLength,samplesPerChunk);


for i = 1:1
   tic
    recordblocking(recObj, chunkLength); 
    

    y = getaudiodata(recObj);
toc
   figure(1)
   
    plot(time_1',y)
    axis([0 chunkLength -.3 .3])
    
    
    NFFT = 2^nextpow2(samplesPerChunk); % Next power of 2 from length of y
    Y = fft(y,NFFT)/samplesPerChunk;
    f = micSampFreq/2*linspace(0,1,NFFT/2+1);
    
    [~,I] = max(abs(Y));
    I
    fprintf('Maximum occurs at %d Hz.\n',f(I));
    
    
    
    
    figure(2)
    % Plot single-sided amplitude spectrum.
    plot(f,2*abs(Y(1:NFFT/2+1)))
    title('Single-Sided Amplitude Spectrum of y(t)')
    xlabel('Frequency (Hz)')
    ylabel('|Y(f)|')
    axis([10^1 5000 0 .15])

end

