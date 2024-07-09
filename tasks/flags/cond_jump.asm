; Demo of conditional jumps

section .text
	global asm_func


asm_func:
	mov ecx, 10
	mov edx, 7

	imul ecx, edx
	cmp ecx, edx
	jl jump1		; won't be taken, ECX (70) is greater than EDX (7)
	jg jump2		; will be taken

jump1:
	mov eax, 1024
	ret

jump2:
	imul edx, 10
	inc edx
	cmp ecx, edx
	jb jump3		; will be taken
	jge jump4		; won't be taken, ECX (70) is less than EDX (71)

jump3:
	mov eax, 65535
	cmp eax, ecx
	je jump5		; won't be taken EAX (65535) != ECX (70)
	ret

jump4:
	mov eax, 0
	ret

jump5:
	mov eax, 1234567890
	ret
