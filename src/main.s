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

  @ Read the file with buffer
  mov r7, #3            
  ldr r1, =buffer   
  ldr r2, =12       @ buffer size
  swi 0   

  ldr r1, =buffer
  @ Load the first 32-bit number into r8
  ldr r8, [r1]            @ load first 32 bits into r8
  @ Load the second 32-bit number into r9
  ldr r9, [r1, #4] 
  
  add r10, r8, r9       @ load next 32 bits (offset by 4 bytes) into r9

  ldr r11, =0x10000000
  str r11, [r1, #8]

  @ Open the file output file
  mov r7, #5            
  ldr r0, =name_output   
  mov r1, #66             
  mov r2, #438            
  swi 0      

  @ Write the buffer of the output file
  mov r7, #4            
  ldr r1, =buffer   
  ldr r2, =12        @ buffer size
  swi 0                   
_end:
  @ Close input
  mov r7, #6              
  swi 0                   

  @ Close output
  mov r7, #6             
  swi 0                  

  @ Finish program
  mov r0, #0             
  mov r7, #1            
  swi 0

