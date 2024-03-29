import wave
import numpy as np

def binary_to_wav(bin_filename, wav_filename, sample_rate):
    """Convertir binario a WAV.
    
    Args:
        bin_filename (str): Nombre del archivo binario de entrada.
        wav_filename (str): Nombre del archivo WAV de salida.
        sample_rate (int): Tasa de muestreo del audio (e.g., 44100, 48000).
    """
    # Leer el archivo binario
    with open(bin_filename, 'rb') as bin_file:
        data = bin_file.read()
    
    # Convertir los datos binarios a un array de numpy de tipo int16
    samples = np.frombuffer(data, dtype=np.int16)
    
    # Escribir los datos en un archivo WAV
    with wave.open(wav_filename, 'wb') as wav_file:
        # Configurar los parámetros del archivo WAV
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16 bits por muestra
        wav_file.setframerate(sample_rate)
        
        # Escribir los frames en el archivo WAV
        wav_file.writeframes(samples.tobytes())
    
    print(f'Archivo {bin_filename} convertido a WAV como {wav_filename}')

# Ejemplo de uso
binary_to_wav('input.bin', 'input.wav', 44100)
