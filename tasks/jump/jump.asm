section .text
	global asm_func

asm_func:
	mov eax, 5
	jmp change_eax

change_eax:
	sub eax, 4
	ret
