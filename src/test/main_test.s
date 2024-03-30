.global _start

.section .data
name_input: .asciz "input.bin"
name_output: .asciz "output.bin"
buffer: .space 10000    @ reserved buffer

.section .text
_start:
  @ Open the input file
  mov r7, #0x5            
  ldr r0, =name_input     
  mov r1, #2              
  mov r2, #0              
  swi 0                   
  mov r4, r0              @ Save the input file descriptor

  @ Initialize read counter to know when to load r8, r9
  mov r6, #0

  @ Read the file with buffer in a loop
read_loop:
  mov r7, #0x3            
  ldr r0, =r4             
  ldr r1, =buffer         
  ldr r2, =10000          @ Adjust buffer size as needed
  swi 0                   
  cmp r0, #0              @ Compare the return value; 0 indicates EOF
  beq process_last        @ If EOF, process last value and jump to close input file

  @ Only load the first two values once
  cmp r6, #0
  beq load_first_two
  b continue_read

load_first_two:
  ldr r8, [r1]            @ Load the first value into r8
  ldr r9, [r1, #4]        @ Load the second value into r9
  add r6, r6, #1          @ Increment read counter

continue_read:
  @ Write the buffer to the output file directly
  mov r7, #0x4            
  ldr r0, =r5             
  swi 0                   

  b read_loop             @ Loop back to read more

process_last:
  @ Load the last value into r10
  ldr r10, [r1, r2, #-4]  @ Load the last 32-bit value into r10

  @ Continue to close input...

  @ The rest of your code for closing files and ending the program remains the same
