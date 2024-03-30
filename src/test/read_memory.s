.global _start

.section .data
	size: .word 10
	memory: .word 0x10000

.section .text
_start:
	ldr r0, =size
	ldr r1, [r0]
	ldr r0, =memory
	str r1, [r0]
_end:
  mov r0, #0
  mov r7, #1
  swi 0
