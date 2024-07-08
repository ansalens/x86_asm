; This program does simple addition of hard coded integers
; It should be compiled with caller.c
section .text
	global asm_func

asm_func:
	mov eax, 0	; initialize the EAX with 0
	add eax, 5
	add eax, 10
	ret
