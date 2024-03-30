.global _start


.section .data
  name_input: .asciz "input.bin"
  name_output: .asciz "output.bin"  
  buffer: .space 1024    @ reserved buffer initialize in zero
  buffer_size: .word 1024 @ immediate value of buffer_size
  circular: .space 22050 @ reserved circular buffer initialize in zero
  circular_size: .word 22050 @ immediate value of buffer_size


.section .text
_start:
  @ Open the file
  mov r7, #5            
  ldr r0, =name_input     
  mov r1, #2              
  mov r2, #0              
  swi 0                   
  mov r4, r0


  @ Open the file output file
  mov r7, #5            
  ldr r0, =name_output   
  mov r1, #66      @ Flags for write-only, create, truncate       
  mov r2, #438     @ Permissions -rw-r--r--
  swi 0      
  mov r5, r0


  mov r6, #0    @ Inicializar contador de bytes leídos/escritos

loop_read:

  @ Read the input.bin with buffer
  mov r7, #3                @ syscall
  ldr r0, =buffer_size
  ldr r2, [r0]              @ r2 load size buffer
  mov r0, r4                @ r0 load input.bin direction
  ldr r1, =buffer           @ r1 buffer direction
  swi 0
  mov r6, r0                @ store how many was read from the file

  @ Check is finished to read or an error was happened
  cmp r6, #0
  ble _end             @ If r6 <= 0, singed less equal

  @ Write on the output.bin with buffer
  mov r7, #4                @ syscall
  mov r0, r5                @ r0 load output.bin direction
  ldr r1, =buffer           @ r1 load buffer direction
  mov r2, r6                @ r2 how many byte were read it
  swi 0

  @ Star again
  b loop_read

_end:
  @ Close input
  mov r7, #6              @ syscall
  mov r0, r4              @ r0 load input.bin direction
  swi 0                   

  @ Close output
  mov r7, #6              @ syscall
  mov r0, r5              @ r0 load input.bin direction
  swi 0                  

  @ Finish program
  mov r0, #0             
  mov r7, #1            
  swi 0
