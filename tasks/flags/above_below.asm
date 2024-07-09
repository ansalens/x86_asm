; This program shows differences between jumps jl, jb and ja

section .text
	global asm_func

asm_func:
	mov al, -1
	mov dh, 1
	cmp al, dh
	jg is_more  ; jump if AL > DH
	jl is_less	; jump if AL < DH

	mov eax, 0
	ret

is_more:
	mov eax, 0
	ret

is_less:
	cmp al, dh
	jb is_below	; jump if AL is below DH (11111111 < 0000001)	

	cmp al, dh
	ja is_above	; jump if AL is above DH (11111111 > 0000001)

	mov eax, 0
	ret

is_below:		; won't be taken, because AL is > DH
	mov eax, 0xbeef
	ret

is_above:		; will be taken
	mov eax, 0x1337
	ret

