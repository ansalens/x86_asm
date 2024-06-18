; This program returns negative of a number using SUB instruction
section .text
	global asm_func

asm_func:
	mov eax, 0
	sub eax, 15	; EAX = EAX - 15
	ret
