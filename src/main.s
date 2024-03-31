.global _start


.section .data
  name_input: .asciz "input.bin"
  name_output: .asciz "output.bin"  
  buffer: .space 1024    @ reserved buffer initialize in zero
  buffer_size: .word 1024 @ immediate value of buffer_size
  circular: .space 22050 @ reserved circular buffer initialize in zero
  circular_size: .word 22050 @ immediate value of buffer_size
  mode: .word 0           @ reserved space memory to save mode
  k: .word 0              @ reserved space memory to save k
  alpha: .word 0           @ reserved space memory to save alpha


.section .text



reverberation:
  push {r4-r11,lr}
  mov r6, r0                @ Initialize byte_read_counter
  mov r8, r1                @ Initialize offset
  mov r9, r2                @ load circular address (n_k)  
  mov r10, r3               @ load buffer address (n)


end_reverberation:
  mov r0, #0
  mov r1, r8
  mov r2, r9
  pop {r4-r11,lr}
  mov pc, lr


inverse:
  push {r4-r11,lr}
  mov r6, r0                @ Initialize byte_read_counter
  mov r8, r1                @ Initialize offset
  mov r9, r2                @ load circular address (n_k)  
  mov r10, r3               @ load buffer address (n)

end_inverse:
  mov r0, #0
  mov r1, r8
  mov r2, r9
  pop {r4-r11,lr}
  mov pc, lr


load_data:
  push {r4-r11,lr}
  mov r4, r0
  mov r5, r1


  @ Read three parameters from input.bin
  mov r7, #3                @ syscall
  mov r0, r4                @ r0 address input.bin
  ldr r1, =buffer           @ r1 buffer direction
  mov r2, #12               @ r2 number of byte to read (3 numbers)
  swi 0

  @ Write three parameters from output.bin
  mov r7, #4                @ syscall
  mov r0, r5                @ r0 address output.bin
  ldr r1, =buffer           @ r1 load buffer direction
  mov r2, #12                @ r2 number of byte to write (3 numbers)
  swi 0


  ldr r0, =buffer           @ load address buffer
  
  @ Save buffer[0] in mode
  ldr r2, [r0, #0]          @ get the element 0 from buffer
  ldr r1, =mode             @ load address mode
  str r2, [r1]              @ save the value in mode


  @ Save buffer[1] in k
  ldr r2, [r0, #4]          @ get the element 1 from buffer
  ldr r1, =k                @ load address k
  str r2, [r1]              @ save the value in k


  @ Save buffer[2] in alpha
  ldr r2, [r0, #8]          @ get the element 2 from buffer
  ldr r1, =alpha            @ load address alpha
  str r2, [r1]              @ save the value in alpha

  @ Set the variables
  mov r6, #0                @ Initialize byte_read_counter
  mov r8, #0                @ Initialize offset
  ldr r9, =circular         @ load circular address (n_k)  
  ldr r10, =buffer          @ load buffer address (n)

  loop_load_data:

    @ Read the input.bin with buffer
    mov r7, #3                @ syscall
    ldr r0, =buffer_size
    ldr r2, [r0]              @ r2 load size buffer
    mov r0, r4                @ r0 load input.bin direction
    ldr r1, =buffer           @ r1 buffer direction
    swi 0
    mov r6, r0                @ store how many was read from the file

    @ Check is finished to read or an error was happened
    mov r0, #0                @ successful exit
    cmp r6, #0
    ble end_load_data         @ If r6 <= 0, singed less equal

    @ call reverberation or inverse
    ldr r0, =mode               
    ldr r11, [r0]               @ load the value of mode on r11

    @ load parameters of the function
    mov r0, r6                  @ r0 parameter (counter byte was read)
    mov r1, r8                  @ r1 parameter (offset)
    mov r2, r9                  @ r2 parameter (n_k init of circular)
    mov r3, r10                 @ r3 parameter (n init of buffer)

    if_reverberation_load_data:
      cmp r11, #1                         @ if r1!=1 go elseif_inverse 
      bne elseif_inverse_load_data        
      bl reverberation                    @ call function reverberation
      b end_if_load_data
    elseif_inverse_load_data:
      cmp r11, #0                         @ if r1!=0 go else
      bne else_load_data                  
      bl inverse                          @ call function inverse
      b end_if_load_data
    else_load_data:
      ldr r0, =0xffffffff                @ failed exit
      b end_load_data                    @ incorrect value of mode (r11)
    end_if_load_data:
    
    mov r8, r1                  @ save the value of the new offset
    mov r9, r2                  @ save the value of the new n_k

    @ Write on the output.bin with buffer
    mov r7, #4                @ syscall
    mov r0, r5                @ r0 load output.bin direction
    ldr r1, =buffer           @ r1 load buffer direction
    mov r2, r6                @ r2 how many byte were read it
    swi 0

    @ Star again
    b loop_load_data
end_load_data:
  pop {r4-r11,lr}
  mov pc, lr



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


  mov r0, r4       @ read input.bin address
  mov r1, r5       @ write output.bin address
  bl load_data


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
