section .text
	global asm_func

asm_func:
	mov eax, 0

alabel:
	mov eax, 10

blabel:
	add eax, eax
	jmp dlabel

clabel:
	mov eax, 69996
	ret

dlabel:
	dec eax
	ret
