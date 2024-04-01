import tkinter as tk
from tkinter import ttk
from tkinter import filedialog
from tkinter import messagebox
import traceback
import os
from wav_to_q import wav_to_q  
from q_to_wav import q_to_wav  

root = tk.Tk()
root.title("Procesador de Audio")

# Inicialización de variables globales
file_path = ""
delay_option = tk.StringVar(value="Fs × 50ms")
reverb_option = tk.IntVar(value=0)
delay_attenuation_options = {"Fs × 50ms": (10, 0.6), "Fs × 250ms": (50, 0.4), "Fs × 500ms": (100, 0.2)}

def open_file_dialog():
    global file_path
    file_path = filedialog.askopenfilename(filetypes=[("Archivos WAV", "*.wav")])
    if file_path:
        file_label.config(text=f"Archivo seleccionado: {file_path}")
        process_file(file_path)
    else:
        file_label.config(text="No se seleccionó ningún archivo.")
        messagebox.showwarning("Advertencia", "No se seleccionó ningún archivo.")

def process_file(file_path):
    try:
        # Obtiene k y alpha del diccionario basado en la selección del usuario en la GUI
        k, alpha = delay_attenuation_options[delay_option.get()]

        
        # Define el nombre del archivo de salida basado en la opción de reverberación
        output_filename = "input.bin"
        
        # Llama a la función de procesamiento
        wav_to_q(True, k, alpha, file_path, output_filename)
        
        # Muestra un mensaje de éxito
        messagebox.showinfo("Procesamiento exitoso", f"Archivo procesado exitosamente: {output_filename}")
    except ValueError as ve:
        messagebox.showerror("Error de Validación", str(ve))
    except Exception as e:
        messagebox.showerror("Error", f"Error al procesar el archivo: {e}")
        traceback.print_exc()

def open_bin_to_wav_window():
    bin_to_wav_window = tk.Toplevel(root)
    bin_to_wav_window.title("Convertir de BIN a WAV")

    file_frame = ttk.Frame(bin_to_wav_window)
    file_frame.pack(padx=10, pady=10)

    bin_file_path_var = tk.StringVar(value="No se seleccionó ningún archivo .bin")
    file_label = ttk.Label(file_frame, textvariable=bin_file_path_var)
    file_label.pack()

    def open_bin_file_dialog():
        bin_file_path = filedialog.askopenfilename(filetypes=[("Archivos BIN", "*.bin")])
        if bin_file_path:
            bin_file_path_var.set(f"Archivo seleccionado: {bin_file_path}")
        else:
            bin_file_path_var.set("No se seleccionó ningún archivo.")
            messagebox.showwarning("Advertencia", "No se seleccionó ningún archivo.")

    def convert_file():
        bin_file_path = bin_file_path_var.get().replace("Archivo seleccionado: ", "")
        if bin_file_path != "No se seleccionó ningún archivo .bin":
            wav_file_path = filedialog.asksaveasfilename(defaultextension=".wav", filetypes=[("Archivos WAV", "*.wav")])
            if wav_file_path:
                try:
                    q_to_wav(bin_file_path, wav_file_path)
                    messagebox.showinfo("Conversión exitosa", f"Archivo convertido a WAV: {wav_file_path}")
                except Exception as e:
                    messagebox.showerror("Error", f"Error al convertir el archivo: {e}")
                    traceback.print_exc()

    select_file_button = ttk.Button(file_frame, text="Seleccionar archivo BIN", command=open_bin_file_dialog)
    select_file_button.pack(pady=(10, 0))

    convert_button = ttk.Button(file_frame, text="Convertir a WAV", command=convert_file)
    convert_button.pack(pady=(10, 0))

# GUI Layout
main_frame = ttk.Frame(root)
main_frame.grid(row=0, column=0, sticky="nsew")
root.grid_rowconfigure(0, weight=1)
root.grid_columnconfigure(0, weight=1)

options_frame = ttk.Frame(main_frame)
options_frame.grid(row=0, column=0, padx=10, pady=10, sticky="nsew")

ttk.Label(options_frame, text="Seleccione el retardo y la atenuación:").grid(row=0, column=0, columnspan=2)

for i, (option, values) in enumerate(delay_attenuation_options.items(), start=1):
    ttk.Radiobutton(options_frame, text=option, value=option, variable=delay_option).grid(row=i, column=0, sticky="w")

reverb_frame = ttk.Frame(main_frame)
reverb_frame.grid(row=1, column=0, padx=10, pady=10, sticky="nsew")

ttk.Checkbutton(reverb_frame, text="Aplicar reverberación", variable=reverb_option, onvalue=1).grid(row=0, column=0, sticky="w")
ttk.Checkbutton(reverb_frame, text="No aplicar reverberación", variable=reverb_option, onvalue=0).grid(row=1, column=0, sticky="w")

file_frame = ttk.Frame(main_frame)
file_frame.grid(row=2, column=0, padx=10, pady=10, sticky="nsew")

file_label = ttk.Label(file_frame, text="No se seleccionó ningún archivo.")
file_label.grid(row=0, column=0, columnspan=2)

open_button = ttk.Button(file_frame, text="Seleccionar archivo WAV", command=open_file_dialog)
open_button.grid(row=1, column=0, padx=(0, 5))

process_button = ttk.Button(file_frame, text="Procesar archivo", command=process_file)
process_button.grid(row=1, column=1, padx=(5, 0))

bin_to_wav_button = ttk.Button(main_frame, text="Convertir BIN a WAV", command=open_bin_to_wav_window)
bin_to_wav_button.grid(row=3, column=0, padx=10, pady=10)

root.mainloop()