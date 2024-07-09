; Program which will jump based on overflow of registers
; by using jo (jump if overflow) instruction

section .text
	global asm_func

asm_func:				; overflows 8-bit AL register
	mov al, 01111111b		; MSB is sign, decimal value: 255
	inc al				; incrementing al, causes overflow

	jo overflow1
	mov eax, 0			; if it's not overflow return 0
	ret

overflow1:				; overflows 16-bit CX register
	mov cx, 0111111111111111b 	; decimal: 65535
	inc cx

	jo overflow2
	mov eax, 1			; if it's not overflow return 1
	ret

overflow2:				; underflowing the AL register
	mov al, 10000000b		; MSB is 1, which means it's -1
	dec al
	jo underflow
	mov eax, 2			; if it's not underflow, return 2
	ret

underflow:
	mov eax, 0x1337
	ret
