section .text
    global asm_func

asm_func:
    mov dl, 10110001b       ; 177
    rol dl, 1               ; 01100011 = 99
    cmp dl, 99
    je equal

    xor eax, eax
    ret

equal:
    mov eax, 0xbabe
    ret
