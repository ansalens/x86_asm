global asm_func			; will be called in our C program

section .text

asm_func:
	mov eax, 70000		; move 70,000 into EAX
	mov cx, 7		; move 7 into lower 16 bits of ECX
	mov dx, cx		; move 7 into lower 16 bits of EDX
	mov ax, dx		; move 7 into lower 16 bits of EAX

	ret
