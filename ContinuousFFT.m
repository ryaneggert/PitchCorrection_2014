%% %% Full Audio Pitch Shifting %% %%

%% Read Audio %%
clear all
[inAudio,fs] = audioread('CScale.wav');
inAudio = inAudio(:,1); % stereo to mono
numSamp = length(inAudio); % number of samples in inAudio
timeScale = linspace(0,numSamp/fs, numSamp);

%% Window Configuration %%

winLen = 2^13; % make sure this is even
winOverlap = 2^12; % make sure this is even
win =hamming(winLen, 'periodic'); % set window type. MATLAB has many.

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
f = (-NFFT/2: (NFFT-1)/2)*fs/NFFT;
for i = 1:winTotalNum
    FFT{i} = fftshift(fft(WindowedSegments{i}, NFFT)/winLen);
    [~,I] = max(abs(FFT{i}));
    winMaxFreq(i) = f(I);
%    fprintf('Maximum occurs at %d Hz.\n',f(I)); 
    % Use above line to display winMaxFreq each loop
end

%% Shifting %%

shiftAmount = 50; % Number of places to circularly shift inAudio FFT.

for i=1:winTotalNum
    oneHalfFFTtoShift{i} = FFT{i}(1:NFFT/2+1); % Take -fs/2 Hz to 0 Hz 
    shiftHalf{i} = circshift(oneHalfFFTtoShift{i}, shiftAmount); % Shift just the neg freqs. (& 0)
    backTogether(1:NFFT/2+1) = shiftHalf{i}; %-fs/2 to 0 of backTogether
    backTogether(NFFT/2+2:NFFT) = -flipud(shiftHalf{i}(2:NFFT/2));% freq_after_zero to fs/2
    toIFFT{i} = backTogether;
    IFFT_base{i} = ifftshift(ifft(ifftshift(toIFFT{i}), winLen, 'symmetric')*NFFT);
    IFFT_magn{i} = abs(IFFT_base{i});
    IFFT_phase{i} = angle(IFFT_base{i});
%     absPhase = zeros(size(1:winLen));
%     for k = 1:winLen
%         absPhase(k) = abs(IFFT_phase{i}(k));
%         if pi/2 <= absPhase(k)  && absPhase(k) <= pi
%             IFFT_magn{i}(k) = -IFFT_magn{i}(k);
%         end
%     end
    IFFT{i} = IFFT_magn{i};
end

%% Reconstructing Audio %%
outAudio = zeros(size(inAudio));
for i=1:winTotalNum
   stagingMatrix = zeros(size(inAudio));
   stagingMatrix(StartIndex(i):EndIndex(i)) = IFFT_base{i};
   outAudio = outAudio + stagingMatrix;
end



%% Low-Pass Filter %%

% All frequency values are in Hz.
% Sampling Frequency

Fpass = 18000;       % Passband Frequency
Fstop = 22000;       % Stopband Frequency
Apass = 1;           % Passband Ripple (dB)
Astop = 80;          % Stopband Attenuation (dB)
match = 'stopband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, fs);
Hd = design(h, 'butter', 'MatchExactly', match);
outAudio_filt = filter(Hd, outAudio);
%% Plot Results %%

figure (1)
clf
hold all

plot(timeScale, inAudio, 'b')
plot(timeScale, outAudio, 'r')
% axis([.5 .8 -.5 .5])
title('inAudio & outAudio')
xlabel('time (s.)')
ylabel('Value')
legend('inAudio', 'outAudio')

figure (2)
clf


semilogy(f, abs(FFT{3}), 'b')
hold all
semilogy(f, abs(toIFFT{3}), 'r')
axis([-5000 5000 10^-6.3 .035]);
title('FFT of inAudio and shifted FFT, "toIFFT"')
xlabel('Frequency [Hz.]')
ylabel('|FFT|')
legend('FFT of inAudio', 'toIFFT')

figure (3)
clf
hold all

plot(1:winTotalNum, -winMaxFreq,'-g.')
title('Maximum Frequency of Each Window')
xlabel('Window Number')
ylabel('Frequency [Hz.]')


figure (5)
clf
hold all

plot(1:winLen, WindowedSegments{5}, 'b')
% plot(timeScale, outAudio, 'r')
plot(1:winLen, abs(toIFFT{5}), 'g')

title('inAudio & outAudio')
xlabel('time (s.)')
ylabel('Value')


%% Playback %%

audiowrite('PitchShift_Output.wav', outAudio, fs)


%% DEBUG %%

% Take FFT of Output %

outSegments{1} = outAudio(StartIndex(1):EndIndex(1));
outWindowedSegments{1} = outSegments{1}.*win;

for i = 2:winTotalNum
    outSegments{i} = outAudio(StartIndex(i):EndIndex(i));
    outWindowedSegments{i} = outSegments{i}.*win; 
end
for i = 1:winTotalNum
    outFFT{i} = fftshift(fft(outWindowedSegments{i}, NFFT)/winLen);
    [~,I] = max(abs(outFFT{i}));
    outwinMaxFreq(i) = f(I);
end

figure (4)
clf


semilogy(f, abs(toIFFT{7}), 'b')
hold all
semilogy(f, abs(outFFT{7}), 'r')
axis([-5000 5000 10^-6.5 .035]);
title('FFT of outAudio')
xlabel('Frequency [Hz.]')
ylabel('|FFT|')
legend('"Predicted" FFT of outAudio','Actual FFT of outAudio')

figure(3)
hold all
plot(1:winTotalNum, -outwinMaxFreq,'-b.')
legend('Input Signal', 'Output Signal', 'Location', 'SouthEast')