; This program will be called like a library from our C program 'caller'

global asm_func		; declare global function

section .text

asm_func:
	mov eax, -1	; this time move negative number
	ret		; return to caller
