; This progam will be called like a library
; We will call it from caller program

global asm_func		; declare our function globally

section .text

asm_func:
	mov eax, 2000000000	; 2 billion
	ret			; return control to caller
