import pyaudio
import wave
import numpy as np
import matplotlib.pyplot as plt

def recording(seconds, outputFilename):
    """
    PyAudio example: Record a few seconds of audio and save to a WAVE file.

    Takes in two inputs: 
        (int) seconds - how long do you want the recording to be?
        (str) outputFilename - self-explanatory

    The function itself has no output, but the resulting .wav file 
    should be in the same directory as the script.
    """
    
    CHUNK = 1024
    FORMAT = pyaudio.paInt16
    CHANNELS = 2
    RATE = 44100
    RECORD_SECONDS = seconds

    if outputFilename[-4:] != '.wav':
        WAVE_OUTPUT_FILENAME = outputFilename + '.wav'
    else:
        WAVE_OUTPUT_FILENAME = outputFilename

    p = pyaudio.PyAudio()

    stream = p.open(format=FORMAT,
                    channels=CHANNELS,
                    rate=RATE,
                    input=True,
                    frames_per_buffer=CHUNK)

    print("* recording")

    frames = []

    for i in range(0, int(RATE / CHUNK * RECORD_SECONDS)):
        data = stream.read(CHUNK)
        frames.append(data)

    print("* done recording, saved file as %s" % WAVE_OUTPUT_FILENAME)

    stream.stop_stream()
    stream.close()
    p.terminate()

    wf = wave.open(WAVE_OUTPUT_FILENAME, 'wb')
    wf.setnchannels(CHANNELS)
    wf.setsampwidth(p.get_sample_size(FORMAT))
    wf.setframerate(RATE)
    wf.writeframes(b''.join(frames))
    wf.close()
    return

if __name__ == "__main__" :
    #create a wav to tinker with
    #recording(5, "oh hey")
    
    #load a file and get the data / necessary params
    waver = wave.open('oh hey.wav', mode='r')
    inputData = waver.readframes(-1)
    inputData = np.fromstring(inputData, 'Int16')
    fs = waver.getframerate() #sampling frequency

    #DFT shenanigans (using numpy's fft)
    FFTinput = np.fft.fft(inputData)
    omega = np.linspace(-1000, 1000, num=len(FFTinput))

    #plotting the thing in frequency domain
    plt.figure(1)
    plt.title('DFT of input')
    plt.plot(omega, FFTinput)
    plt.show()

    

