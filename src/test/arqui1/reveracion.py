import numpy as np

def read_binary_file(filename):
    """Lee un archivo binario y devuelve los datos como un arreglo de numpy."""
    with open(filename, 'rb') as f:
        data = np.fromfile(f, dtype=np.float32)  # Asume datos en punto flotante de 32 bits
    return data

def write_to_binary_file(data, filename):
    """Escribe un arreglo de numpy a un archivo binario."""
    with open(filename, 'wb') as f:
        data.tofile(f)

def apply_reverb(data, alpha, k):
    """Aplica efecto de reverberación a los datos de audio.
    
    Args:
        data: Arreglo de numpy con los datos de audio.
        alpha: Coeficiente de atenuación.
        k: Retardo en número de muestras.
        
    Returns:
        Un arreglo de numpy con el efecto de reverberación aplicado.
    """
    output = np.zeros_like(data)
    for n in range(len(data)):
        if n < k:
            output[n] = data[n]
        else:
            output[n] = (1 - alpha) * data[n] + alpha * data[n - k]  # Utilizando la ecuación de reverberación
    return output

# Parámetros de configuración para el efecto de reverberación
alpha = 0.2  # Asegúrate de que 0 <= alpha <= 1
k = 4410  # Asumiendo 44100 Hz como frecuencia de muestreo y un retardo de 100 ms

# Nombre del archivo binario de entrada
input_binary_file = 'input.bin'

# Nombre del archivo binario de salida con el efecto de reverberación aplicado
output_binary_file = 'reverbed_audio.bin'

# Leer el archivo binario de entrada
input_data = read_binary_file(input_binary_file)

# Aplicar efecto de reverberación
reverbed_data = apply_reverb(input_data, alpha, k)

# Escribir los datos con el efecto de reverberación aplicado en un archivo binario
write_to_binary_file(reverbed_data, output_binary_file)

print(f"El efecto de reverberación se ha aplicado al archivo '{input_binary_file}' y se ha guardado en '{output_binary_file}'.")
