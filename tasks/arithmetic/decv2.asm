; Decrement program without DEC instruction
section .text
	global asm_func

asm_func:
	mov eax, 256
	sub eax, 1
	ret
