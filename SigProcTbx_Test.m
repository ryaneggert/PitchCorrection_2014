
t = 0:.01:1-0.01;
Fs = 1e3;
x = sin(2*pi*70*t)+3*cos(2*pi*40*t);
x = detrend(x,0);
xdft = fft(x);
freq = 0:Fs/length(x):Fs/2;
xdft = xdft(1:length(x)/2+1);
plot(freq,abs(xdft));
[~,I] = max(abs(xdft));
fprintf('Maximum occurs at %d Hz.\n',freq(I));


