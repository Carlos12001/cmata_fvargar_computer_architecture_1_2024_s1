import numpy as np
from scipy.io import wavfile

def convert_to_mono(wav_file):
    """Convierte un archivo WAV de dos canales a un solo canal."""
    # Cargar el archivo WAV
    sample_rate, data = wavfile.read(wav_file)
    
    # Extraer un solo canal (por ejemplo, el primer canal)
    mono_data = data[:, 0]  # Seleccionar solo el primer canal
    
    # Crear un nuevo archivo WAV con un solo canal
    output_file = 'input.wav'  # Nombre del archivo de salida
    wavfile.write(output_file, sample_rate, mono_data)
    
    return output_file

# Nombre del archivo WAV de entrada con dos canales
input_wav_file = 'ranitauwu.wav'

# Convertir el archivo a un solo canal
input_wav = convert_to_mono(input_wav_file)

print(f"El archivo WAV '{input_wav_file}' se ha convertido a un solo canal y se ha guardado como '{input_wav}'.")
