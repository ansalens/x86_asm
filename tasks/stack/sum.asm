sum:
	push	ebp
	mov	ebp, esp
	mov	edx, DWORD PTR 8[ebp]
	mov	eax, DWORD PTR 12[ebp]
	add	eax, edx
	pop	ebp
	ret
main:
	push	ebp
	mov	ebp, esp
	push	30
	push	20
	call	sum
	add	esp, 8
	leave
	ret
