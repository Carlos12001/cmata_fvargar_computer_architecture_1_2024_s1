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

    
multiply_fixed_point:
  push {r4-r8, lr}
  mov r7, r2
  mov r2, #32
  sub r8, r2, r7
  
  mov r2, r0
  mov r3, r1
  cmp r0, #0
  rsbmi r0, r0, #0

  cmp r1, #0
  rsbmi r1, r1, #0
  umull r4, r5, r0, r1
  eor r2, r2, r3

  tst r2, #0x80000000
  rsbmi r4, r4, #0
  rsbmi r5, r5, #0
  orrmi r4, r4, #0x80000000
  mov r6, r7

  lsr r4, r4, r6
  orr r4, r4, r5, lsl r8
  mov r0, r4
end_multiply_fixed_point:
  pop {r4-r8, pc}

@ Aplica la reverberation utiliza los valores del buffer (x[n])
@ usa el y_old que se obtiene de circular[n_k-k] y guarda tanto en el
@ calcula el y[n] y guarda en el circular[n_k] en la posicion actual n_k
@ y deja el resultado en buffer remplazando los x[n].
@ Parametros  
@ r0: numero de bits leidos  (max_iter)
@ r1: posicion del circular (n_k)
@ Retorna
@ r0: si tuvo exito el algoritmo
@ r1: la posicion del circular que es n_k
reverberation:
  push {r4-r11,lr}
  mov r6, r0                @ Initialize byte_read_counter
  mov r8, r1                @ load circular address (n_k)  
  
  ldr r0, =circular_size
  ldr r7, [r0] @ load value circular_size into r7
  ldr r10, =buffer @ load address into r11
  mov r11, r10 @ load address into r11
  ldr r12, =circular @ load address into r12

  for_reverberation:
    add r0, r11, r6    @ max value address of buffer (buffer+counter_byte_read)
    cmp r10, r0         @ compare buffer counter (n) and max value address buffer
    bhs end_for_reverberation @ if r10>=r0 goto end_for

    ldr r0, =k
    ldr r4, [r0] @ load value k into r4
    sub r0, r8, r4    @ Make n_k - k
    if_circular_access_reverberation:
      cmp r0, r12     @ n_k-k < circular
      blo else_circular_access_reverberation
      ldr r3, [r0]     @ y_old = circular [n_k-k]
      b end_if_circular_access_reverberation
    else_circular_access_reverberation:
      @ lsl r1, r7, #2
      @ ldr r3, [r0, r1]     @ y_old = circular [n_k - k + 4*circular_size]
      ldr r3, [r0, r7]     @ y_old = circular [n_k - k + circular_size]
    end_if_circular_access_reverberation:

    @ apply reverberation
    @ mov r5, r3          @ saved y_old
    @ mov r2, #30         @ set format q=r2
    @ mov r0, #1          
    @ lsl r0, r0, r2      @ get 1 in format q
    @ ldr r3, =alpha
    @ ldr r1, [r3]        @ load value alpha into r1
    @ sub r1, r0, r1      @ 1 - alpha
    @ ldr r0, [r10]       @ load x[n] value into r0
    @ bl multiply_fixed_point
    @ mov r4, r0          @ saved r4 = (1-alpha)*x[n]
    @ ldr r3, =alpha      
    @ ldr r0, [r3]        @ r0 = alpha
    @ mov r1, r5          @ r1 = y_old
    @ mov r2, #30         @ set format q=r2
    @ bl multiply_fixed_point
    @ mov r5, r0          @ saved r5 =  alpha*y_old
    @ add r3, r4, r5      @ saved y = (1-alpha)*x[n] + alpha*y_old    


    ldr r0, [r10]       @ load x[n] value into r0
    @ apply reverberation
    @ add r0, r0, #1      @ temp = x[n] + 1
    @ add r3, r3, r0      @ y[n] = temp + y_old 

    add r3, r0, #0      @ y[n] = x[n] + 0


    @ save on circular y[n] to replace last y_old used
    str r3, [r8]         @ save value y[n] on circular
    add r8, #4       @ increase n_k+4 to advanced in circular
    
    @ lsl r1, r7, #2
    @ add r0, r12, r1   @ circular + 4*circular_size
    add r0, r12, r7   @ circular + circular_size
    @ Check if n_k need to return original address circular
    if_nk_max_reverberation:
      cmp r8, r0      @ n_k < (circular) + circular_size
      blo end_if_nk_max_reverberation
      ldr r8, =circular   @ return to initial address circular
    end_if_nk_max_reverberation:


    @ save on buffer y[n] to replace last x[n]
    str r3, [r10]      @ write y[n] in buffer
    add r10, #4 @ increase address n
    b for_reverberation

  end_for_reverberation:
  mov r0, #0
  mov r1, r8

end_reverberation:
  pop {r4-r11,lr}
  mov pc, lr


inverse:
  push {r4-r11,lr}
  mov r6, r0                @ Initialize byte_read_counter
  mov r8, r1                @ load circular address (n_k)  
  
  ldr r0, =circular_size
  ldr r7, [r0] @ load value circular_size into r7
  ldr r10, =buffer @ load address into r11
  mov r11, r10 @ load address into r11
  ldr r12, =circular @ load address into r12

  for_inverse:
    add r0, r11, r6    @ max value address of buffer (buffer+counter_byte_read)
    cmp r10, r0         @ compare buffer counter (n) and max value address buffer
    bhs end_for_inverse @ if r10>=r0 goto end_for

    ldr r0, =k
    ldr r4, [r0] @ load value k into r4
    sub r0, r8, r4    @ Make n_k - k
    if_circular_access_inverse:
      cmp r0, r12     @ n_k-k < circular
      blo else_circular_access_inverse
      ldr r3, [r0]     @ x_old = circular [n_k-k]
      b end_if_circular_access_inverse
    else_circular_access_inverse:
      @ lsl r1, r7, #2
      @ ldr r3, [r0, r1]     @ x_old = circular [n_k - k + 4*circular_size]
      ldr r3, [r0, r7]     @ x_old = circular [n_k - k + circular_size]
    end_if_circular_access_inverse:

    @ apply inverse
    @ mov r5, r3          @ saved x_old
    @ mov r2, #30         @ set format q=r2
    @ mov r0, #1          
    @ lsl r0, r0, r2      @ get 1 in format q
    @ ldr r3, =alpha
    @ ldr r1, [r3]        @ load value alpha into r1
    @ sub r1, r0, r1      @ 1/(1 - alpha)
    @ ldr r0, [r10]       @ load x[n] value into r0
    @ bl multiply_fixed_point
    @ mov r4, r0          @ saved r4 = 1/(1-alpha)*x[n]
    @ ldr r3, =alpha      
    @ ldr r0, [r3]        @ r0 = alpha
    @ mov r1, r5          @ r1 = x_old
    @ mov r2, #30         @ set format q=r2
    @ bl multiply_fixed_point
    @ mov r5, r0          @ saved r5 =  alpha/(1 - alpha)*x_old
    @ add r3, r4, r5      @ saved y = 1/(1-alpha)*x[n] + alpha/(1 - alpha)*x_old    


    ldr r0, [r10]       @ load x[n] value into r0
    @ apply inverse
    @ add r0, r0, #1      @ temp = x[n] + 1
    @ add r3, r3, r0      @ y[n] = temp + x_old 

    add r3, r0, #0      @ y[n] = x[n] + 0

    ldr r0, [r10]       @ load x[n] value into r0
    @ save on circular y[n] to replace last y_old used
    str r0, [r8]         @ save value x[n] on circular
    add r8, #4       @ increase n_k+4 to advanced in circular
    
    @ lsl r1, r7, #2
    @ add r0, r12, r1   @ circular + 4*circular_size
    add r0, r12, r7   @ circular + circular_size
    @ Check if n_k need to return original address circular
    if_nk_max_inverse:
      cmp r8, r0      @ n_k < (circular) + circular_size
      blo end_if_nk_max_inverse
      ldr r8, =circular   @ return to initial address circular
    end_if_nk_max_inverse:


    @ save on buffer y[n] to replace last x[n]
    str r3, [r10]      @ write y[n] in buffer
    add r10, #4 @ increase address n
    b for_inverse

  end_for_inverse:
  mov r0, #0
  mov r1, r8

end_inverse:
  pop {r4-r11,lr}
  mov pc, lr

@ Funcion que se encargar de cargar 1024 bytes en el buffer de leida
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
  ldr r8, =circular         @ load circular address (n_k)  

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
    
    mov r8, r1                  @ save the value of the new n_k

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
