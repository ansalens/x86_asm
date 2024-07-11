section .text
    global asm_func

asm_func:
    mov al, 00000011b   ; 3
    shl al, 3           ; 00011000b = 24
    cmp al, 00011000b
    je l1

    xor eax, eax
    ret

l1:
    mov al, 00000110b   ; 6
    mov cl, 0x2         ; can only use CL!
    shr al, cl          ; 00000001b
    cmp al, 00000001b
    je l2

    mov eax, 1
    ret

l2:                     ; arithmetic shift right
    mov al, -16         ; 10010000b
    sar al, 1           ; 01001000b
    cmp al, -8
    je l3

    mov eax, 2
    ret

l3:
    mov al, 128             ; 10000000b
    shr al, 7               ; 00000001b
    ror al, 8               ; 00000001b
    cmp al, 1
    je l4

    mov eax, 3
    ret

l4:
    mov eax, 1              ; 000000001b
    ror eax, 1              ; 1 is transferred to MSB of the 4th byte
    ret
