global asm_func

section .text

asm_func:
	mov eax, 2000000000		; move one billion to EAX
	mov al, 7			; move 200 to lower 8 bits of EAX

	ret
