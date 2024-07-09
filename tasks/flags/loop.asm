; This program calculates 9^3 by looping over for ECX times

section .text
	global asm_func

asm_func:
	mov eax, 9		; base number
	mov edx, eax
	mov ecx, 2		; loop counter

start:
	dec ecx
	imul eax, edx		; 1st 9*9=81, 2st 81*9=729
	cmp ecx, 0		; ecx - 0
	jne start		; if ecx isn't zero yet, loop one more time
	je end			; if ecx is zero, jump to the end

end:
	ret
