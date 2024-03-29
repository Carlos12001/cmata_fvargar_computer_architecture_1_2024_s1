import wave
import numpy as np

def wav_to_q15_16(wav_filename, bin_filename, k, alpha):
    """
    Convert WAV to binary format, with additional parameters k and alpha.
    
    Parameters:
    wav_filename (str): Name of the input WAV file.
    bin_filename (str): Name of the output binary file.
    k (int): An unsigned integer parameter.
    alpha (float): A parameter in Q15.16 format.
    """
    with wave.open(wav_filename, "rb") as wav_file:
        # Read the parameters
        nchannels, sampwidth, framerate, nframes, comptype, compname = wav_file.getparams()
        
        # Ensure the audio is mono, has a sample rate of 44100 Hz, and does not exceed 15 seconds
        if nchannels != 1 or framerate != 44100 or nframes/framerate > 15:
            raise ValueError("Audio must be mono, with a sample rate of 44100 Hz, and no longer than 15 seconds")
        
        # Read frames
        frames = wav_file.readframes(nframes)
        
        # Convert to numpy array
        audio_samples = np.frombuffer(frames, dtype=np.int16)
        
        # Normalize the samples to range [-1, 1]
        normalized_samples = audio_samples / 2**15
        
        # Convert to Q15.16
        q15_16_samples = np.int32(normalized_samples * 2**16)
        
        # Prepare k and alpha for writing; k as uint32, alpha remains in Q15.16 format
        k_uint32 = np.array([k], dtype=np.uint32)
        # Alpha is provided and already in Q15.16 format, but let's ensure it's an integer for storage
        alpha_int32 = np.int32(alpha * 2**16) if not isinstance(alpha, int) else alpha
        
        # Write to binary file
        with open(bin_filename, "wb") as bin_file:
            k_uint32.tofile(bin_file)  # Write k
            bin_file.write(alpha_int32.tobytes())  # Write alpha
            q15_16_samples.tofile(bin_file)  # Write audio data

if __name__ == '__main__':
    s = "src/"
    wav_to_q15_16(s + "ranita.wav", s + "input.bin", 10, 0.6)
