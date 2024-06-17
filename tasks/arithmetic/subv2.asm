section .text
	global asm_func

asm_func:
	mov ecx, 20
	mov edx, 13
	sub ecx, edx	; 20-13 and move the result to ECX
	mov eax, ecx	; move the result into EAX
	ret

