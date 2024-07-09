global asm_func

section .text

asm_func:
	mov ecx, 10
	mov edx, 15
	cmp ecx, edx
	jl jumpjl

	mov eax, 1
	ret


jumpjl:
	mov eax, 512
	ret
