global asm_func

section .text

asm_func:
	mov eax, 9
	cmp eax, 5
	jne jumpjne	; if eax != 5

	mov eax, 7
	ret

jumpjne:
	mov eax, 255
	ret
