global asm_func

section .text

asm_func:
	mov eax, 10
	mov ecx, 5
	cmp eax, ecx
	jg jumpjg	; if EAX > ECX

	mov eax, 7
	ret

jumpjg:
	mov eax, 255
	ret
