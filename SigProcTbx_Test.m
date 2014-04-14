
t = 0:.001:1-0.001;
Fs = 1e3;
x = 2+sin(2*pi*70*t)+3*cos(2*pi*40*t);
x = detrend(x,0);
xdft = fft(x);
freq = 0:Fs/length(x):Fs/2;
xdft = xdft(1:length(x)/2+1);
plot(freq,abs(xdft));
[~,I] = max(abs(xdft));
fprintf('Maximum occurs at %d Hz.\n',freq(I));





psdest = psd(spectrum.periodogram,x,'Fs',Fs,'NFFT',length(x));
[~,I] = max(psdest.Data);
fprintf('Maximum occurs at %d Hz.\n',psdest.Frequencies(I));