#!/bin/bash

# Detiene el script en caso de errores
set -e
# Asegura que los errores en pipelines sean capturados
set -o pipefail

# Ensambla el archivo fuente
arm-linux-gnueabi-as main_test.s -o main.o

# Enlaza el objeto para crear el ejecutable
arm-linux-gnueabi-ld main.o -o main

# Crea un dump de desensamblado
arm-linux-gnueabi-objdump -d main &> main.disassembly

# Ejecuta el binario en QEMU y espera a la conexión del debugger
qemu-arm -g 1234 ./main &

# Espera un poco a que QEMU se inicie correctamente
sleep 2

# Inicia GDB
gdb-multiarch -q -ex "target remote localhost:1234" main
