import struct
import csv

def format_hex(byte_value):
    """
    Format a byte value into a hexadecimal string representation.

    Args:
        byte_value (bytes): The byte value to be formatted.

    Returns:
        str: The formatted hexadecimal string representation of the byte value.
    """
    return " ".join(f"{b:02x}" for b in byte_value)

def format_bin(byte_value):
    """
    Format a byte value into a binary string with spaces every 4 bits.
    
    :param byte_value: The byte value to be formatted
    :return: A string representing the formatted binary value
    """
    return " ".join(f"{b:08b}"[:4] + "-" + f"{b:08b}"[4:] for b in byte_value)

def read_and_convert(file_path, csv_path, q=30):
    """
    Reads binary data from a file, converts it to various formats, and 
    writes the formatted data to a CSV file.

    Parameters:
        file_path (str): The path to the binary file to be read.
        csv_path (str): The path to the CSV file where the formatted 
          data will be written.
        q (int, optional): The quantization factor used to convert the 
          signed integer to float. Defaults to 30.

    Returns:
        None
    """
    with    (open(file_path, "rb") as bin_file,
            open(csv_path, "w", newline="") as csv_file):
        writer = csv.writer(csv_file)
        writer.writerow(["index", "hex", "bin", "signed decimal", "float"])
        
        index = 0
        while True:
            # Read 4 bytes (32 bits)
            bytes_read = bin_file.read(4)
            if not bytes_read:
                break
            
            # Unpack the bytes to a signed integer
            int_value = struct.unpack("i", bytes_read)[0]
            
            # Convert the signed integer to float (demonstration purposes)
            float_value = float(int_value) / (2**q) # Example conversion
            
            # Write the formatted data to the CSV
            writer.writerow([
                index,
                format_hex(bytes_read),
                format_bin(bytes_read),
                int_value,
                float_value
            ])
            
            index += 4

if __name__ == "__main__":
    from tkinter import Tk
    from tkinter.filedialog import askopenfilename
    # Initialize the GUI window and hide it
    Tk().withdraw()
    # Open a file selection dialog and get the file path
    file_path = askopenfilename(title='Select binary file', 
    filetypes=[('Binary files', '*.bin')])
    if file_path: # If a file was selected
        csv_path = 'output.csv' # Define the CSV output path
        read_and_convert(file_path, csv_path)