section .text
	global asm_func

asm_func:
	mov eax, 10
	sub eax, 3	; subtracts 3 from 10 and puts the result into EAX
	ret
