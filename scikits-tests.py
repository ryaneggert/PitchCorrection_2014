# import numpy as np
# import scikits.audiolab

# # data = np.random.uniform(-1,1,44100)
# data = np.fromfile(open('oh hey.wav'),np.uint8)[24:]
# print data

# # write array to file:
# #scikits.audiolab.wavwrite(data, 'test.wav', fs=44100, enc='pcm16')
# # play the array:
# scikits.audiolab.play(data)#, fs=44100)

from scipy.io import wavfile
import scikits.audiolab

fs, data = wavfile.read('oh hey.wav')
print data[2:]
print data.shape
scikits.audiolab.play(data,fs)