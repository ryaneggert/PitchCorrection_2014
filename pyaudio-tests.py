import pyaudio
import wave
import numpy as np
import matplotlib as plt

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
    #recording(5, "oh hey")
    waver = wave.open('oh hey.wav', mode='r')
    data = waver.readframes(-1)

    data = np.fromstring(data, 'uint8')
    data = data / 2**15.
    fs = waver.getframerate()
    print fs

    # print waver
    # print waver.getnchannels()
    # print waver.getsampwidth()
    # print waver.getframerate()
    # print waver.getnframes()
    # print waver.getcomptype()
    # readframes =  waver.readframes(10)
    # print [ord(i) for i in readframes]