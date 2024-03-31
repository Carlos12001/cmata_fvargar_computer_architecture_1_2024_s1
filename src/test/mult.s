.section .text
.global _start

multiply_fixed_point:
  PUSH {R4-R6, LR}
  MOV R2, R0
  MOV R3, R1
  CMP R0, #0
  RSBMI R0, R0, #0

  CMP R1, #0
  RSBMI R1, R1, #0
  UMULL R4, R5, R0, R1
  EOR R2, R2, R3

  TST R2, #0x80000000
  RSBMI R4, R4, #0
  RSBMI R5, R5, #0
  ORRMI R4, R4, #0x80000000
  MOV R6, #30

  LSR R4, R4, R6
  ORR R4, R4, R5, LSL #2
  MOV R0, R4
  POP {R4-R6, PC}


_start:
  ldr r10, =0xeccccccd         @-0.3
  ldr R11, =0x2ccccccd         @0.7
  
  mov r0, r10
  mov r1, r10
  BL multiply_fixed_point
  mov r4, r0  @0.09
  
  mov r0, r11
  mov r1, r11
  BL multiply_fixed_point
  mov r5, r0 @0.49
  
  mov r0, r10
  mov r1, r11
  BL multiply_fixed_point
  mov r6, r0  @-0.21
  
  mov r0, r11
  mov r1, r10
  BL multiply_fixed_point
  mov r7, r0 @-0.21

 
  
  B .                           

