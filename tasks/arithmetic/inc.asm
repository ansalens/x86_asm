; Simple program that increments the number using INC instruction
section .text
	global asm_func

asm_func:
	mov eax, 13
	inc eax		; increment EAX by 1 and store it into EAX, EAX = EAX + 1
	inc eax		; 15
	ret
