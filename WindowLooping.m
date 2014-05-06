%% Window Looping %%%% Window Testing %%
clear all

numSamp = 80000;
inAudio = zeros([1 numSamp]);

numLengths = 100;
numOverlaps = 100;

winLens = pow2(linspace(4,14.7, numLengths));
Overlaps = linspace(49, 51, numOverlaps);


for wl = 1:numLengths
    for wo = 1:numOverlaps
        winLen = winLens(wl); % make sure this is even
        percentOverlap = Overlaps(wo)/100;
        winOverlap =  2*round(winLen*percentOverlap/2); % make sure this is even
        win =hamming(winLen, 'periodic')'; % Hamming Window
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
         
        range(outWinVis(2*winLen:(numSamp-(2*winLen))))
%         
%         figure (1) % Visualization of Window Overlap
%         clf
%         hold all
%         
%         plot(1:numSamp, outWinVis, 'b')
%         axis([1*(winLen) 6*(winLen)  0 1.5])
%         title('Windowing Visualization')
%         xlabel('time (s.)')
%         ylabel('Value')
%         OverlapMovie(i) = getframe;
    end
end


