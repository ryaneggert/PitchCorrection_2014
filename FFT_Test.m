micSampFreq = 44100;

recObj = audiorecorder(micSampFreq, 16, 1);




for i = 1:300
    
    samplesPerChunk = 1024;
    
    chunkLength = samplesPerChunk/micSampFreq;
    
    recordblocking(recObj, chunkLength);
    


    y = getaudiodata(recObj);

   figure(1)
   
    plot(y)
    axis([0 samplesPerChunk -.3 .3])
    
    
    samplesize = size(y);
    L = samplesize(1);
    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    Y = fft(y,NFFT)/L;
    f = micSampFreq/2*linspace(0,1,NFFT/2+1);
    
    figure(2)
    % Plot single-sided amplitude spectrum.
    plot(f,2*abs(Y(1:NFFT/2+1)))
    title('Single-Sided Amplitude Spectrum of y(t)')
    xlabel('Frequency (Hz)')
    ylabel('|Y(f)|')
    axis([10^1 4000 0 .08])
end

