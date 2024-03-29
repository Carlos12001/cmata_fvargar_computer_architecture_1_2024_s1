.global _start


.section .data
  name_input: .asciz "input.bin"
  name_output: .asciz "output.bin"  
  buffer: .space 10000    @ reserved buffer

.section .text
_start:
  @ Open the file
  mov r7, #0x5            
  ldr r0, =name_input     
  mov r1, #2              
  mov r2, #0              
  swi 0                   

  @ Read the file with buffer
  mov r7, #0x3            
  ldr r1, =buffer   
  ldr r2, =#8       @ buffer size
  swi 0   

 ldr r1, =buffer
  @ Load the first 32-bit number into r8
  ldr r8, [r1]            @ load first 32 bits into r8
  @ Load the second 32-bit number into r9
  ldr r9, [r1, #4] 
  
  add r10, r8, r9       @ load next 32 bits (offset by 4 bytes) into r9

  @ Open the file output file

  @ @ Write the buffer of the output file
  @ mov r7, #0x4            
  @ ldr r1, =buffer   
  @ ldr r2, =8        @ buffer size
  @ swi 0                   
_end:
  @ Close input
  mov r7, #6              
  swi 0                   

  @ @ Close output
  @ mov r7, #6             
  @ swi 0                  

  @ Finish program
  mov r7, #0x1            
  mov r0, #0             
  swi 0

