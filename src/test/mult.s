.section .text
.global _start

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
  pop {r4-r8, pc}

  

_start:
  ldr r10, =0xfccccccd         @-0.2 fccccccd
  ldr R11, =0xfe666666       @-0.1  f8000000
  
  mov r0, r10
  mov r1, r10
  mov r2, #28
  BL multiply_fixed_point
  mov r5, r0  @0.04 00a3d70a
  
  mov r0, r11
  mov r1, r11
  mov r2, #28
  BL multiply_fixed_point
  mov r6, r0 @0.01 0028f5c3  
  
  mov r0, r10
  mov r1, r11
  mov r2, #28
  BL multiply_fixed_point
  mov r7, r0  @0.02 0051eb85
  
  mov r0, r11
  mov r1, r10
  mov r2, #28
  BL multiply_fixed_point
  mov r8, r0 @0.02 0051eb85

 
  
  B .                           
