section .text
	global asm_func

asm_func:
	mov eax, 0
	mov ecx, 5

	start:			; start of the loop
		add eax, 1
		loop start	; loops until ecx drops to 0

	ret
