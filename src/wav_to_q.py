import wave
import numpy as np

def wav_to_q(mode,k,alpha,wav_filename,bin_filename="input.bin",q=30):
    """
    Convert WAV to binary format, with additional parameters k and alpha.
    
    Parameters:
    k (int): An unsigned integer parameter.
    alpha (float): A parameter in Q format.
    wav_filename (str): Name of the input WAV file.
    bin_filename (str): Name of the output binary file.
    q (int): Number of bits for the fractional part of the output.
    """
    if not isinstance(mode, bool):
        raise TypeError("reverberation must be a boolean")
    if not isinstance(k, int):
        raise TypeError("k must be an integer")
    if not isinstance(alpha, float):
        raise TypeError("alpha must be a float")
    if not isinstance(q, int):
        raise TypeError("q must be an integer")
    if k < 0:
        raise ValueError("k must be non-negative")
    if alpha < 0 or 1 < alpha:
        raise ValueError("alpha must be in the range [0, 1]")
    if 7 < q and q < 30:
        raise ValueError("q must be in the range [7, 30]")

    with wave.open(wav_filename, "rb") as wav_file:
        # Read the parameters
        (nchannels, sampwidth, framerate, nframes,
        comptype, compname) = wav_file.getparams()
        
        # Check audio parameters
        if nchannels != 1:
            raise ValueError("Audio must be mono")
        if framerate != 44100:
            raise ValueError("Audio must have a sample rate of 44100 Hz")
        if nframes/framerate > 15:
            raise ValueError("Audio must be no longer than 15 seconds")
        
        # Read frames
        frames = wav_file.readframes(nframes)
        
        # Convert to numpy array
        audio_samples = np.frombuffer(frames, dtype=np.int16)
        
        # Normalize the samples to range [-1, 1]
        normalized_samples = audio_samples / 2**15
        
        # Convert to Q floating point
        q_samples = np.int32(normalized_samples * 2**q)

        # Prepare mode for writing
        r_uinit32 = np.array([int(mode)], dtype=np.uint32)
        
        # Prepare k and alpha for writing; k as uint32, alpha as Q format
        k_uint32 = np.array([k*4], dtype=np.uint32)
        alpha_int32 = np.int32(alpha * 2**q)
        # last_number = np.int32(0.5*2**q)
        
        # Write to binary file
        with open(bin_filename, "wb") as bin_file:
            r_uinit32.tofile(bin_file)  # Write mode
            k_uint32.tofile(bin_file)  # Write k
            bin_file.write(alpha_int32.tobytes())  # Write alpha
            q_samples.tofile(bin_file)  # Write audio data
            # bin_file.write(last_number.tobytes())

if __name__ == "__main__":
    from tkinter import Tk
    from tkinter.filedialog import askopenfilename
    # Initialize the GUI window and hide it
    Tk().withdraw()
    # Open a file selection dialog and get the file path
    file_path = askopenfilename(title='Select binary file', 
    filetypes=[('Binary files', '*.wav')])
    if file_path: # If a file was selected

        k = 10
        alpha = 0.6
        wavfile = file_path
        output = "input.bin"
        
        
        try:
            wav_to_q(True,k,alpha,wavfile,output)

            print(( f"The file {wavfile} was successfully converted to {output}"
                    f" with k={k} and alpha={alpha}."))
        
        except Exception as e:
            print(f"An error occurred: {e}")
