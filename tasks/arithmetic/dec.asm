; Simple decrement program using DEC instruction
section .text
	global asm_func

asm_func:
	mov eax, 65536
	dec eax		; decrements the EAX, same as EAX = EAX - 1
	ret
