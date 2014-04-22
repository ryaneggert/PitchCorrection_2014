micSampFreq = 880*2; %FFT MaxFreq = micSampFreq/2
recObj = audiorecorder(micSampFreq, 16, 1);

samplesPerChunk = 2^15;

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
    f = [-NFFT/2: (NFFT-1)/2]*micSampFreq/NFFT;
    
    [~,I] = max(abs(Y));
    I
    fprintf('Maximum occurs at %d Hz.\n',f(I));
    
    
    
    
    figure(2)
    % Plot single-sided amplitude spectrum.
    plot(f,abs(fftshift(Y)))
    title('Single-Sided Amplitude Spectrum of y(t)')
    xlabel('Frequency (Hz)')
    ylabel('|Y(f)|')
    axis([-5000 5000 0 .15])

end

