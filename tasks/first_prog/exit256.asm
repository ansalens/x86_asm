section .text
	global _start

_start:
	mov eax, 1				; prepare for exit()
	mov ebx, 256			; put exit code into ebx
	int 0x80					; make syscall
