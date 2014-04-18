%% %% Full Audio Pitch Shifting %% %%

%% Read Audio %%

[inAudio,fs] = audioread('CScale.wav');
inAudio = inAudio(:,1); % stereo to mono
numSamp = length(inAudio); % number of samples in inAudio
timeScale = linspace(0,numSamp/fs, numSamp);

%% Window Configuration %%

winLen = 2^12; % make sure this is even
winOverlap = 2^11; % make sure this is even
win = hamming(winLen,'periodic'); % set window type. MATLAB has many.

winTotalNum = floor((winOverlap - (numSamp + 1))/(winOverlap - winLen));  
             % maximum number of windows w/o overrunning the end of inAudio.

%% Segments %%

StartIndex(1) = 1;
EndIndex(1) = winLen;
Segments{1} = inAudio(StartIndex(1):EndIndex(1));
WindowedSegments{1} = Segments{1}.*win;

for i = 2:winTotalNum
    StartIndex(i) = (i-1)*(winLen-winOverlap);
    EndIndex(i) = (i*winLen-((i-1)*winOverlap))-1;
    Segments{i} = inAudio(StartIndex(i):EndIndex(i));
    WindowedSegments{i} = Segments{i}.*win; 
end

%% FFT %%

NFFT = 2^nextpow2(winLen);
f = fs/2*linspace(0,1,NFFT/2+1);
for i = 1:winTotalNum
    FFT{i} = fft(WindowedSegments{i}, NFFT)/winLen;
    [~,I] = max(abs(FFT{i}));
    winMaxFreq(i) = f(I);
%    fprintf('Maximum occurs at %d Hz.\n',f(I)); 
    % Use above line to display winMaxFreq each loop
end

%% Shifting %%

shiftAmount = 10; % Number of places to circularly shift inAudio FFT.

for i=1:winTotalNum
    toIFFT{i} = circshift(FFT{i}, shiftAmount); % Circularly shift 
    IFFT{i} = ifft(toIFFT{i}, winLen)*NFFT;
end

%% Reconstructing Audio %%
outAudio = zeros(size(inAudio));
for i=1:winTotalNum
   stagingMatrix = zeros(size(inAudio));
   stagingMatrix(StartIndex(i):EndIndex(i)) = IFFT{i};
   outAudio = outAudio + stagingMatrix;
end

%% Plot Results %%

figure (1)
clf
hold all

plot(timeScale, inAudio, 'b')
plot(timeScale, outAudio, 'r')
axis([.5 .6 -.5 .5])
title('inAudio & outAudio')
xlabel('time (s.)')
ylabel('Value')
legend('inAudio', 'outAudio')

figure (2)
clf
hold all

plot(f, abs(FFT{7}(1:NFFT/2+1)), 'b')
plot(f, abs(toIFFT{3}(1:NFFT/2+1)), 'r')
axis([0 5000 0 .035]);
title('FFT of inAudio and shifted FFT, "toIFFT"')
xlabel('Frequency [Hz.]')
ylabel('|FFT|')
legend('FFT of inAudio', 'toIFFT')

figure (3)
clf
hold all

plot(1:winTotalNum, winMaxFreq,'-g.')
title('Maximum Frequency of Each Window')
xlabel('Window Number')
ylabel('Frequency [Hz.]')


%% Playback %%

audiowrite('PitchShift_Output.wav', outAudio, fs)


%% Misc. %%

%UNUSED%