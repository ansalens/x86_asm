section .text
	global _start

_start:
	mov eax, 0x4		; use write syscall (4)
	mov ebx, 0x1		; this is file descriptor which is 1 (stdout)
	mov ecx, helloStr	; put the address of helloStr into ecx
	mov edx, len		; size of our string plus newline

	int 0x80		; invoke the syscall interrupt

	
	; gracefully exit the program

	mov eax, 0x1		; use exit syscall
	xor ebx, ebx		; faster way of saying status code is 0

	int 0x80		; invoke syscall


	section .data:				; data segment
	helloStr: db "Hello, world!", 0xA	; add string + \n
	len: equ $ -helloStr			; gets length of string
