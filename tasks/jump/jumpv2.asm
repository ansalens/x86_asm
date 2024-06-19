section .text
	global asm_func

asm_func:
	mov eax, 120
	jmp jump_to_this

never_executed:		; this is skipped as long as there is jmp in line 6
	mov eax, 685

jump_here_now:			; label for later jump
	add eax, 15
	ret			; last jump must return control to asm_func

jump_to_this:			; label for first jump
	add eax, eax		; doubles the eax
	jmp jump_here_now	; jumps to another label
