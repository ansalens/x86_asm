global asm_func

section .text

asm_func:
	mov eax, -1
	mov ecx, -1
	cmp eax, ecx
	jbe jumpjbe
	
	mov eax, 0
	ret

jumpjbe:
	mov eax, 255
	ret
