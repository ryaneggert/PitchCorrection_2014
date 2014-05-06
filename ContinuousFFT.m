%% %% Full Audio Pitch Shifting %% %%

%% Read Audio %%
clear all
<<<<<<< HEAD
[inAudio,fs] = audioread('800_hz.wav');
=======
[inAudio,fs] = audioread('CScale2.wav');
>>>>>>> f0dee94004b778703af8d4f7051dacf84373b7ce
inAudio = inAudio(:,1); % stereo to mono
numSamp = length(inAudio); % number of samples in inAudio
timeScale = linspace(0,numSamp/fs, numSamp);

%% Window Configuration %%

<<<<<<< HEAD
winLen = 2^18; % make sure this is even
winOverlap =  2*round(winLen*.5/2); % make sure this is even
win =hamming(winLen, 'periodic'); % Hamming Window
% win = ones([winLen 1]); % Homemade Rectangular Window
=======
winLen = 2^13; % make sure this is even
winOverlap =  2*round(winLen*.73/2); % make sure this is even
win = flattopwin(winLen, 'periodic'); % Hamming Window
win = ones([winLen 1]); % Homemade Rectangular Window
winOverlap= 0;
>>>>>>> f0dee94004b778703af8d4f7051dacf84373b7ce

winTotalNum = floor((winOverlap - (numSamp + 1))/(winOverlap - winLen));
% maximum number of windows w/o overrunning the end of inAudio.

%% Segments %%

StartIndex(1) = 1;
EndIndex(1) = winLen;
Segments{1} = inAudio(StartIndex(1):EndIndex(1));
WindowedSegments{1} = Segments{1}.*win;

for i = 2:winTotalNum
    StartIndex(i) = (i-1)*(winLen-winOverlap); % Creates a list of window starting indices
    EndIndex(i) = (i*winLen-((i-1)*winOverlap))-1; % Creates a list of window ending indices
    Segments{i} = inAudio(StartIndex(i):EndIndex(i)); % Splits inAudio into segments
    WindowedSegments{i} = Segments{i}.*win; % Creates windowed segments
end

%% FFT %%

NFFT = 2^nextpow2(winLen); % FFTs are most efficient for 2^n sized data. Find the next greatest power of two.
f = (-NFFT/2: (NFFT-1)/2)*fs/NFFT; % Generates a vector of frequencies for use with fftshift-ed data.
freqRes = abs(f(5)-f(4)); % Calculates the frequency resolution of this run.
for i = 1:winTotalNum
    FFT{i} = fftshift(fft(WindowedSegments{i}, NFFT)/winLen); % Take FFT of each window. Note 1/winLen term
    [~,I] = max(abs(FFT{i})); % Identify index of maximum value of each window's FFT (magnitude of)
    winMaxFreq(i) = f(I); % Save maximum value to a vector
    %    fprintf('Maximum occurs at %d Hz.\n',f(I));
    % Use above line to display winMaxFreq each loop
end

%% Shifting %%

for i=1:winTotalNum
    [targetFreq(i), shiftAmount] = pitchshift(-winMaxFreq(i), freqRes); % Use 1 when using synth-strings
    
    oneHalfFFTtoShift{i} = FFT{i}(1:NFFT/2+1); % Take -fs/2 Hz to 0 Hz
    shiftHalf{i} = circshift(oneHalfFFTtoShift{i}, shiftAmount); % Shift just the neg freqs. (& 0)
    backTogether(1:NFFT/2+1) = shiftHalf{i}; %-fs/2 to 0 of backTogether
    backTogether(NFFT/2+2:NFFT) = -flipud(shiftHalf{i}(2:NFFT/2));% freq_after_zero to fs/2
    toIFFT{i} = backTogether;
    
    IFFT_base{i} = ifft(ifftshift(toIFFT{i}), winLen, 'symmetric')*NFFT; % Take IFFT of shifted freq-domain signal
    
end

%% Reconstructing Audio %%
outAudio = zeros(size(inAudio)); % Create zero vector into which we will arrange our pitch-shifted windows
for i=1:winTotalNum
    stagingMatrix = zeros(size(inAudio)); % Create a zero vector into which we will arrainge one pitch-shifted window
    stagingMatrix(StartIndex(i):EndIndex(i)) = IFFT_base{i}; % Arrange one pitch-shifted window using the same indices used to define it
    outAudio = outAudio + stagingMatrix; % Add vector--this sums window overlap
end

%% Plot Results %%

figure (1) % Time-domain signal comparison plot
clf
hold all

plot(timeScale, inAudio, 'b')
plot(timeScale, outAudio, 'r')
% axis([.5 .8 -.5 .5])
title('inAudio & outAudio')
xlabel('time (s.)')
ylabel('Value')
legend('inAudio', 'outAudio')

figure (2) % Input FFT and theoretical output FFT
clf
semilogy(f, abs(FFT{3}), 'b', 'LineWidth', 1.5)
hold all
semilogy(f, abs(toIFFT{3}), 'r', 'LineWidth', 1.5)
axis([-5000 5000 10^-6.3 .035]);
title('FFT of inAudio and shifted FFT, "toIFFT"')
xlabel('Frequency [Hz.]')
ylabel('|FFT|')
legend('FFT of inAudio', 'toIFFT')

figure (3) % "Maximum Frequency" identified from input signal FFT (& output signal FFT)
clf
hold all

plot(1:winTotalNum, -winMaxFreq,'-g*', 'MarkerSize', 6, 'LineWidth', 2)
title('Maximum Frequency of Each Window')
xlabel('Window Number')
ylabel('Frequency [Hz.]')


figure (5) % Input Audio and Output Signal Window Comparison
clf
hold all

plot(1:winLen, WindowedSegments{5}, 'b')
plot(1:winLen, IFFT_base{5}, 'g')

title('inAudio & outAudio (window 5)')
xlabel('samples')
ylabel('Value')

figure(6) % Representation of each window's "snapping" frequency
clf
plot(1:winTotalNum, targetFreq,'-m*', 'MarkerSize', 6, 'LineWidth', 2)
hold all
title('Snap Frequency of Each Window')
xlabel('Window Number')
ylabel('Frequency [Hz.]')


%% Playback %%

audiowrite('PitchShift_Output.wav', outAudio, fs) % Ouput a WAV audio file for listening


%% Window Visualization %%

winVisVect = ones(size(inAudio)); % Create a vector of ones as large as the input signal
winVisSegments{1} = winVisVect(StartIndex(1):EndIndex(1)); % Split this into segments (first value)
winVisWindowedSegments{1} = winVisSegments{1}.*win; % Apply the window to each segment (first value)

for i = 2:winTotalNum
    winVisSegments{i} = winVisVect(StartIndex(i):EndIndex(i)); % Split this into segments 
    winVisWindowedSegments{i} = winVisSegments{i}.*win; % Apply the window to each segment
end

outWinVis = zeros(size(inAudio)); % Reconstruct windowed segments as done in "%% Reconstructing Audio %%"

for i=1:winTotalNum
    winVisStagingMatrix = zeros(size(inAudio));
    winVisStagingMatrix(StartIndex(i):EndIndex(i)) = winVisWindowedSegments{1};
    outWinVis = outWinVis + winVisStagingMatrix;
end


figure (7) % Visualization of Window Overlap
clf
hold all

plot(timeScale, outWinVis, 'b')
axis([4*(winLen/fs) 9*(winLen/fs)  -2 2])
title('Windowing Visualization')
xlabel('time (s.)')
ylabel('Value')


%% DEBUG %%

% Take FFT of Output %

outSegments{1} = outAudio(StartIndex(1):EndIndex(1)); % Segment the outAudio vector (first value)
outWindowedSegments{1} = outSegments{1}.*win; % Window the outAudio vector (first value)

for i = 2:winTotalNum
    outSegments{i} = outAudio(StartIndex(i):EndIndex(i)); % Segment the outAudio vector
    outWindowedSegments{i} = outSegments{i}.*win; % Window the outAudio vector
end

for i = 1:winTotalNum
    outFFT{i} = fftshift(fft(outWindowedSegments{i}, NFFT)/winLen); % Take the fft (and fftshift() it) of each outAudio windowed segment
    [~,I] = max(abs(outFFT{i})); % Identify index of maximum value of each window's FFT (magnitude of)
    outwinMaxFreq(i) = f(I); % Save maximum value to a vector
end

figure (4) % Comparison of theoretical outAudio FFT and actual outAudio FFT
clf

hold all
semilogy(f, abs(outFFT{7}), 'r')
semilogy(f, abs(toIFFT{7}), 'b')
axis([-5000 5000 10^-6.5 .035]);
title('FFT of outAudio')
xlabel('Frequency [Hz.]')
ylabel('|FFT|')
legend('Actual FFT of outAudio','"Predicted" FFT of outAudio')

figure(3) % "Maximum Frequency" identified from output signal FFT (& input signal FFT)
hold all
plot(1:winTotalNum, -outwinMaxFreq,'-b*', 'MarkerSize', 6, 'LineWidth', 2) % Note: take opposite of outwinMaxFreq
legend('Input Signal', 'Output Signal', 'Location', 'SouthEast')

%% ANIMATION %%
<<<<<<< HEAD
% 
% inAudio FFT %
% figure(8)
% 
% for i = 1:winTotalNum % Plot each input signal windowed segment's FFT and capture a frame [of each]
%     clf
%     semilogy(f, abs(FFT{i}), 'b', 'LineWidth', 1.5)
%     axis([-2000 2000 10^-8 .04]);
%     title('FFT of inAudio')
%     xlabel('Frequency [Hz.]')
%     ylabel('|FFT|')
%     inAudioFFTMovie(i) = getframe;
% end
% 
% % outAudio FFT %
=======

% inAudio FFT %
figure(8)

% for i = 1:winTotalNum % Plot each input signal windowed segment's FFT and capture a frame [of each]
for i = 7
    clf
    semilogy(f, abs(FFT{i}), 'b', 'LineWidth', 1.5)
    axis([-2000 2000 10^-12 .1]);
    title('FFT of inAudio')
    xlabel('Frequency [Hz.]')
    ylabel('|FFT|')
    inAudioFFTMovie(i) = getframe;
end

% outAudio FFT %
>>>>>>> f0dee94004b778703af8d4f7051dacf84373b7ce
% figure(9)
% 
% for i = 1:winTotalNum % Plot each output signal windowed segment's FFT and capture a frame [of each]
%     clf
%     semilogy(f, abs(outFFT{i}), 'r', 'LineWidth', 1.5)
<<<<<<< HEAD
%     axis([-2000 2000 10^-8 .04]);
=======
%     axis([-2000 2000 10^-12 .1]);
>>>>>>> f0dee94004b778703af8d4f7051dacf84373b7ce
%     title('FFT of outAudio')
%     xlabel('Frequency [Hz.]')
%     ylabel('|FFT|')
%     outAudioFFTMovie(i) = getframe;
% end
<<<<<<< HEAD
% 
=======

>>>>>>> f0dee94004b778703af8d4f7051dacf84373b7ce
% movie(inAudioFFTMovie, 1, fs/winLen) % Movie playback (inAudio)
% movie(outAudioFFTMovie, 1, fs/winLen) % Movie playback (outAudio)
% movie2avi(inAudioFFTMovie, 'inAudioFFTMovie.avi', 'compression', 'None'); % Export movie (inAudio)
% movie2avi(outAudioFFTMovie, 'outAudioFFTMovie.avi', 'compression', 'None'); % Export movie (outAudio)
