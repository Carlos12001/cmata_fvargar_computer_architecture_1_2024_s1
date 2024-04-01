import tkinter as tk
from tkinter import ttk
from tkinter import filedialog
from tkinter import messagebox

# Asumiendo que las funciones están definidas en estos módulos
from wav_to_q import wav_to_q
import q_to_wav

def open_file_dialog():
    global file_path
    file_path = filedialog.askopenfilename(filetypes=[("Archivos WAV", "*.wav")])
    if file_path:
        file_label.config(text=f"Archivo seleccionado: {file_path}")
    else:
        messagebox.showwarning("Advertencia", "No se seleccionó ningún archivo.")

def process_file():
    global file_path
    if not file_path:
        messagebox.showwarning("Advertencia", "No se seleccionó ningún archivo.")
        return
    
    k, alpha = delay_attenuation_options[delay_option.get()]
    output_filename = "processed_output.bin" if reverb_option.get() == 1 else "input.bin"
    
    # Llamar a la función para convertir .wav a .bin
    try:
        wav_to_q(k, alpha, file_path, output_filename)
        messagebox.showinfo("Procesamiento exitoso", f"Archivo procesado exitosamente: {output_filename}")
    except Exception as e:
        messagebox.showerror("Error", f"Error al procesar el archivo: {e}")



    x_center = width // 2
    y_center = height // 2
    
    file_label.place(x=x_center, y=y_center, anchor="center")
    open_button.place(x=x_center-200, y=y_center+30, anchor="center")
    process_button.place(x=x_center+200, y=y_center+30, anchor="center")

root = tk.Tk()
root.title("Procesador de Audio")

delay_option = tk.StringVar(value="Fs × 50ms")
reverb_option = tk.IntVar(value=0)  # 0 para no aplicar, 1 para aplicar

ttk.Label(root, text="Seleccione el retardo y la atenuación:").pack()

delay_attenuation_options = {"Fs × 50ms": (10, 0.6), "Fs × 250ms": (50, 0.4), "Fs × 500ms": (100, 0.2)}
for option in delay_attenuation_options.keys():
    ttk.Radiobutton(root, text=option, value=option, variable=delay_option).pack()

ttk.Checkbutton(root, text="Aplicar reverberación", variable=reverb_option, onvalue=1).pack()
ttk.Checkbutton(root, text="No aplicar reverberación", variable=reverb_option, onvalue=0).pack()

file_label = ttk.Label(root, text="No se seleccionó ningún archivo.")
open_button = ttk.Button(root, text="Seleccionar archivo WAV", command=open_file_dialog)
process_button = ttk.Button(root, text="Procesar archivo", command=process_file)

file_label.place(relx=0.5, rely=0.5, anchor="center")
open_button.place(relx=0.5, rely=0.5, anchor="center")
process_button.place(relx=0.5, rely=0.5, anchor="center")

root.bind("<Configure>", on_resize)

root.mainloop()
