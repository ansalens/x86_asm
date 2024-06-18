; Unsigned multiplication with MUL instruction
section .text
	global asm_func

asm_func:
	mov eax, 0	; initialize
	mov al, 15 
	mov ah, 25
	mul ah 		; within EAX multiply AH with AL, EAX = AH * AL
	ret
