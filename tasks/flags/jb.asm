global asm_func

section .text

asm_func:
	mov ecx, -1
	mov edx, -1

	sub ecx, 1
	cmp ecx, edx
	jb jumpjb
	
	mov eax, 1
	ret

jumpjb:
	mov eax, 7
	ret
