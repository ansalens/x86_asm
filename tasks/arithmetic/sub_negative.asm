section .text
	global asm_func

asm_func:
	mov ecx, 8
	mov edx, 9
	sub ecx, edx	; ECX = ECX - EDX = -1
	mov eax, ecx
	ret
