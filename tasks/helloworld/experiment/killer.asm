section .text
	global _start

_start:
	mov eax, 0x25		; kill syscall (37 dec)
	mov ebx, 0x6518		; pid of lsof command
	mov ecx, 0xE		; send signal 15 SIGTERM

	int 0x80		; call the syscall

	; exit return 0

	mov eax, 1
	xor ebx, ebx
	int 0x80
