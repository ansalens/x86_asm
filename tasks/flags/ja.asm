global asm_func

section .text

asm_func:
	mov eax, -1	; -1 in unsigned way is 2^N-1
	mov ecx, 10
	cmp eax, ecx
	ja jmpja

	mov eax, 7
	ret

jmpja:
	mov eax, 255
	ret
