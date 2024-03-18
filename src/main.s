.global _start

.section .data
  file_path: .asciz "input.bin"
  buffer: .space 4

.section .text
_start:

  // fopen("input.bin", "rb")

  ldr r0, =file_path    // direccion del nombre del archivo en memoria
  mov r1, #0            // 0 = O_RDONLY, abrir para lectura
  mov r7, #5            // 5 = sys_open
  svc 0                 // Realizar llamada al sistema
  mov r4, r0            // Guardar el descriptor de archivo en r4 (asumiendo éxito)

_open_check: 
  // fread(buffer, size, count, filePointer)

  ldr r0, =buffer       // Dirección del buffer
  mov r1, r4            // Descriptor de archivo
  mov r2, #4            // Leer 4 bytes (tamaño de unsigned int)
  mov r7, #3            // 3 = sys_read
  svc 0                 // Realizar llamada al sistema

_read_check:

  // leer el valor
  ldr r8, [r0]         // Carga el valor leído en r8

  // fclose(filePointer)
  mov r0, r4            // Descriptor de archivo
  mov r7, #6            // 6 = sys_close
  svc 0                 // Realizar llamada al sistema


_exit:
  mov r0, #0            // Código de salida
  mov r7, #1            // 1 = sys_exit
  svc 0                 // Realizar llamada al sistema
