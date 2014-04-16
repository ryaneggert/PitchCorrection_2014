pause(20)
for i = 1:1000
    i

micSampFreq = 900+i*100; %FFT MaxFreq = micSampFreq/2
recObj = audiorecorder(micSampFreq, 16, 1);

samplesPerChunk = 1024;
chunkLength = samplesPerChunk/micSampFreq;
time_1 = linspace(0,chunkLength,samplesPerChunk);

recordblocking(recObj, chunkLength); 
    
y = getaudiodata(recObj);
NFFT = 2^nextpow2(samplesPerChunk); % Next power of 2 from length of y
Y = fft(y,NFFT)/samplesPerChunk;
f = micSampFreq/2*linspace(0,1,NFFT/2+1);
    
[~,I] = max(abs(Y));
MaxFreq(i) = f(I);
end
MicFreq = 900+100*(1:1000);

figure(3)
clf
hold all
plot(MicFreq, MaxFreq);
