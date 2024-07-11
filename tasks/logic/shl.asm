; This program shows that shifting left by 2 bits
; is the same as multiplicating the operand by 4.

section .text
    global asm_func:

asm_func:
    mov al, 00111111b   ; 63
    shl al, 2           ; 11111100b = 252
    cmp al, 252
    je equal

    xor eax, eax
    ret

equal:
    mov eax, 0x1337
    ret
