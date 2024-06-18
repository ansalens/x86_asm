; Manually increment the number using ADD instruction
section .text
	global asm_func


asm_func:
	mov eax, 6
	add eax, 1
	ret
