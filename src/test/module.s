.global _start
	
.section .text	
module:
  PUSH {LR}            @ Save return address
  CMP R1, #0           @ Check if divisor is 0
  BEQ module_end       @ Exit if divisor is 0

  module_loop:
    CMP R0, R1       @ Compare dividend with divisor
    BLT module_end   @ Exit loop if R0 < R1
    SUB R0, R0, R1   @ Subtract divisor from dividend
    B module_loop    @ Repeat loop
    
module_end:
  POP {PC}             @ Restore return address and return


_start:
  MOV R0, #15
  MOV R1, #10
  BL module

  B .
