section .text
	global asm_func

asm_func:
	mov ecx, 10
	mov edx, 5
	add ecx, edx	; add contents of EAX and EBX and put it into EAX
	mov eax, ecx
	ret
