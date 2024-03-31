.section .text
.global _start

multiply_fixed_point:
  PUSH {R4-R6, LR}              @ Guarda los registros en la pila

  MOV R2, R0                    @ Copia el primer operando
  MOV R3, R1                    @ Copia el segundo operando

  CMP R0, #0                    @ Compara R0 con 0
  RSBMI R0, R0, #0              @ Si R0 < 0, entonces R0 = -R0 (valor absoluto)
  CMP R1, #0                    @ Compara R1 con 0
  RSBMI R1, R1, #0              @ Si R1 < 0, entonces R1 = -R1 (valor absoluto)

  UMULL R4, R5, R0, R1          @ Multiplica R0 por R1, resultado en R4:R5

  EOR R2, R2, R3                @ XOR entre los signos originales
  TST R2, #0x80000000           @ Prueba el bit de signo
  RSBMI R4, R4, #0              @ Si el signo original era negativo, negar el resultado
  RSBMI R5, R5, #0              @ Igual para R5, si es necesario (dependiendo de cómo quieras manejar el alto)
  ORRMI R4, R4, #0x80000000     @ Establece el bit de signo si el resultado debe ser negativo

  MOV R6, #30                   @ Prepara para ajustar el resultado
  LSR R4, R4, R6                @ Desplaza R4 a la derecha para ajustar el resultado
  ORR R4, R4, R5, LSL #2        

  MOV R0, R4                    @ Mueve el resultado final a R0
  POP {R4-R6, PC}               @ Restaura registros y retorna
  

_start:
  ldr r0, =0xd0000000         @ Primer número
  ldr R1, =0xd0000000           @ Segundo número
  BL multiply_fixed_point       @ Llama a la función
  
  B .                           @ Bucle infinito
