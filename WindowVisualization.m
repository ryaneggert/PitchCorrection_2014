%% Window Testing %%
clear all

numSamp = 50000;
inAudio = zeros([1 numSamp]);


winLens = round(pow2(linspace(4,14.7,5000)));
pct = linspace(0, .85, 200);
pct = .75
for k = 1:1
    winLen = 2^13; % make sure this is even
    percentOverlap = pct(k)
    winOverlap =  2*round(winLen*percentOverlap/2); % make sure this is even
    win =blackmanharris(winLen, 'periodic')'; % Hamming Window
    % win = ones([winLen 1]); % Homemade Rectangular Window
    
    winTotalNum = floor((winOverlap - (numSamp + 1))/(winOverlap - winLen));
    
    
    StartIndex(1) = 1;
    EndIndex(1) = winLen;
    for i = 2:winTotalNum
        StartIndex(i) = (i-1)*(winLen-winOverlap); % Creates a list of window starting indices
        EndIndex(i) = (i*winLen-((i-1)*winOverlap))-1; % Creates a list of window ending indices
    end
    
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
    
    
    THEFIG = figure (1); % Visualization of Window Overlap
    clf
    hold all
    
    plot(1:numSamp, outWinVis, 'b')
    PctReadout = strcat('Percent Overlap: ', num2str(percentOverlap*100), '%');
    text(20000,2, PctReadout)
    axis([0 6*(winLen)  0 4])
    title('Hamming Summation')
    xlabel('Samples')
    ylabel('Value')
%     OverlapMovie(k) = getframe(THEFIG);
%     RangeData(k) = range(outWinVis(2*winLen:(numSamp-(2*winLen))));
end

