section .text
	global _start

_start:
	mov edx, 10	; move 10 to EDX
	mov eax, edx	; move 10 to EAX
	mov ecx, edx	; move 10 to ECX
	mov ebx, ecx	; move 10 to EBX

	mov eax, 1	; move 1 into EAX

	int 0x80	; exit syscall

