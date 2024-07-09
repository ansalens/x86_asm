; Demo of je (jump if equal) conditional jump

global asm_func

section .text

asm_func:
	mov eax, 6
	mov ecx, 5
	cmp eax, ecx	; EAX - ECX
	je jejump	; if EAX - ECX = 0

	mov eax, 7
	ret

jejump:
	mov eax, 255
	ret
