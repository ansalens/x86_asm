; Program that will return negative of a number using NEG instruction
section .text
	global asm_func

asm_func:
	mov eax, 0	; initialize
	mov ah, 128
	mov al, 2
	mul ah		; 128 * 2 = 256
	dec eax		; 256 - 1 = 255
	neg eax		; negates the number
	ret
