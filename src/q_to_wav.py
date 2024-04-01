import numpy as np
import wave

def q_to_wav(bin_filename, wav_filename, q=28):
    """
    Convert a binary file back to WAV format, removing the initial k and alpha values.
    
    Parameters:
    bin_filename (str): Name of the input binary file.
    wav_filename (str): Name of the output WAV file.
    q (int): Number of bits for the fractional part of the input.
    """
    with open(bin_filename, "rb") as bin_file:
        # Read and ignore k and alpha values
        k = np.fromfile(bin_file, dtype=np.uint32, count=1)
        alpha = np.fromfile(bin_file, dtype=np.int32, count=1)
        
        # Read the Q formatted audio data
        q_samples = np.fromfile(bin_file, dtype=np.int32)
        
    # De-transform the Q values to normalized float values
    normalized_samples = q_samples / 2**q
    
    # De-normalize to original audio sample range
    audio_samples = np.int16(normalized_samples * 2**15)
    
    # Save as a WAV file
    with wave.open(wav_filename, "wb") as wav_file:
        # Set parameters: 
        # mono channel, 2 bytes per sample, 44100 sample rate,
        # number of frames, uncompressed format
        wav_file.setparams((1, 2, 44100, len(audio_samples), "NONE", 
                            "not compressed"))
        
        # Write audio data
        wav_file.writeframes(audio_samples.tobytes())

if __name__ == "__main__":
    from tkinter import Tk
    from tkinter.filedialog import askopenfilename
    # Initialize the GUI window and hide it
    Tk().withdraw()
    # Open a file selection dialog and get the file path
    file_path = askopenfilename(title='Select binary file', 
    filetypes=[('Binary files', '*.bin')])
    if file_path: # If a file was selected

        bin_filename = file_path
        wav_filename = "output.wav"
        
        try:
            q_to_wav(bin_filename, wav_filename)
            print((f"The file {bin_filename} was successfully converted back"
                f"to {wav_filename}."))
        except Exception as e:
            print(f"An error occurred: {e}")