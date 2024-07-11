; This program shows that arithmetic shift by 2 bits to the right
; is the same as dividing that number by 4, while keeping MSB bit.

section .text
    global asm_func

asm_func:
    mov al, 192
    neg al
    sar al, 2
    cmp al, -48     ; this is supposed to be true but it's not
    je equal

    xor eax, eax
    ret

equal:
    mov eax, 0x1337
    ret

