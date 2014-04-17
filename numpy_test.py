import numpy as np
import matplotlib.pyplot as plt

pi = np.pi

t = np.arange(0,20.48, .0001)
sp = np.fft.fft(np.sin(2*pi*440*t)+np.sin(2*pi*220*t)+5*np.sinc(t))
freq = np.fft.fftfreq(t.shape[-1], .0001)
print t.shape[-1]
plt.plot(freq, sp.real)
plt.show()