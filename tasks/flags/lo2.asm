section .text
	global asm_func

asm_func:
	mov eax, 5
	mov ecx, 5

	peach:
		dec eax			; decrement eax every loop
		cmp eax, ecx
		loopne peach		; loop as long as eax = ecx, and ecx != 0

	ret
