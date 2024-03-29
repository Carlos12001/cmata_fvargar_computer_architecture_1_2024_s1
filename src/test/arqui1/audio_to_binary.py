import wave
import numpy as np

def wav_to_binary(wav_filename, binary_filename):
    """Convertir WAV a binario.
    
    Args:
        wav_filename (str): Nombre del archivo WAV de entrada.
        binary_filename (str): Nombre del archivo binario de salida.
    """
    with wave.open(wav_filename, 'rb') as wav_file:  # Corregido aquí
        # Asegurarse de que el archivo es mono.
        nchannels = wav_file.getnchannels()
        if nchannels != 1:
            raise ValueError(f"El archivo {wav_filename} tiene {nchannels} canales. Este script solo maneja audio mono.")

        # Leer frames y convertir a numpy array.
        frames = wav_file.readframes(wav_file.getnframes())
        samples = np.frombuffer(frames, dtype=np.int16)

    # Asegurarse de que la escritura al archivo binario se realiza dentro de la función
    with open(binary_filename, 'wb') as bin_file:
        # Escribir los datos directamente al archivo binario
        bin_file.write(samples.tobytes())

    print(f'Archivo {wav_filename} convertido a binario como {binary_filename}')

# Ejemplo de uso
if __name__ == "__main__":
    wav_to_binary('ranitauwu_mono.wav', 'input.bin')


