.section .text
.global _start

multiply_fixed_point:
  PUSH {R4-R6, LR}           @ Save registers and return address

  UMULL R4, R5, R0, R1       @ Multiply R0 by R1, result in R4 (low) and R5 (high), para no sobrescribir R1 y R2

  MOV R6, #30                @ Prepare to shift by 30 bits to adjust for fixed point
  LSR R4, R4, R6             @ Shift the lower bits of the result to the right by 30
  ORR R4, R4, R5, LSL #2     @ Combine with the upper bits shifted. El resultado ajustado ahora está en R4.

  MOV R0, R4                 @ Mueve el resultado ajustado a R0, manteniendo R1 y R2 intactos con los valores originales
  POP {R4-R6, PC}            @ Restore registers and return
  

_start:
  MOV R0, #(1<<30)           @ Primer número en Q1.30, equivalente a 0.25
  MOV R1, R0                 
  BL multiply_fixed_point    

  B .                        

