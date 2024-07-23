; This is what foobar looks like in assembly,
; Notice that this output is trimmed to only show foobar and most important code.
foobar:
    ; Save ebp across calls
	push ebp
    ; ebp now points to stack
	mov	ebp, esp
    ; make space for variables
	sub	esp, 16
    ; eax has value of parameter a that is passed to the function
    ; then adds 2 to it, this is xx local variable
    ; then stores it into the stack
	mov	eax, DWORD PTR 8[ebp]
	add	eax, 2
	mov	DWORD PTR -16[ebp], eax         ; xx

    ; eax now holds the value of b
    ; it adds 3 to it, this is yy
    ; and stores it into the stack (above xx)
	mov	eax, DWORD PTR 12[ebp]
	add	eax, 3
	mov	DWORD PTR -12[ebp], eax         ; yy

    ; eax now holds the value of c
    ; it adds 4 to it, this is zz
    ; and stores it into the stack (above yy)
	mov	eax, DWORD PTR 16[ebp]
	add	eax, 4
	mov	DWORD PTR -8[ebp], eax          ; zz

    ; This begins adding up all the variables
    ; first it moves xx into edx
    ; then it moves yy into eax
    ; then adds both numbers and stores it into edx
	mov	edx, DWORD PTR -16[ebp]
	mov	eax, DWORD PTR -12[ebp]
	add	edx, eax
    ; moves zz into eax
    ; adds eax and edx and stores it into eax
    ; this is variable sum and it's stored in the stack also
	mov	eax, DWORD PTR -8[ebp]
	add	eax, edx
	mov	DWORD PTR -4[ebp], eax          ; sum


	mov	eax, DWORD PTR -16[ebp]
	imul eax, DWORD PTR -12[ebp]        ; multiply xx with yy
	imul eax, DWORD PTR -8[ebp]         ; multiply the previous result with zz
	mov	edx, eax
	mov	eax, DWORD PTR -4[ebp]
	add	eax, edx                        ; add sum with the previous result and return it

	leave
	ret
