global asm_func

section .text

asm_func:
	mov eax, 10
	cmp eax, 10
	jge jumpjge	; if EAX >= 10

	mov eax, 7
	ret

jumpjge:
	mov eax, 255
	ret
