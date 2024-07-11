; This program shows how rotating register CL to the right by 1 bit works.

section .text
    global asm_func

asm_func:
    mov cl, 10101011b
    ror cl, 1               ; 11010101
    cmp cl, 213
    je equal

    xor eax, eax
    ret

equal:
    mov eax, 0xFF
    ret
