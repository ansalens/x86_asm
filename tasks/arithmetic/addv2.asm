; This program uses different registers for adding the numbers
section .text
	global asm_func

asm_func:
	mov ecx, 10
	mov edx, 5
	add ecx, edx	; add contents of ECX and EDX and put it into ECX
	mov eax, ecx
	ret
