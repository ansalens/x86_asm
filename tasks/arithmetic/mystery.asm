section .text
	global asm_func

asm_func:
	mov ebx, -10
	imul eax, ebx, -5
	ret
