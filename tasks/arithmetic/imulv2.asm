section .text
	global asm_func

asm_func:
	mov ecx, -10
	imul eax, ecx, -5
	ret
