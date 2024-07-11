; This program shows arithmetic shift to the left by 2 bits is the same
; as multiplicating that number by 4.

section .text
    global asm_func

asm_func:
    mov al, 00000011b       ; 3
    neg al                  ; -3
    sal al, 2               ; -3*4 = -12
    cmp al, -12
    je equal

    xor eax, eax
    ret

equal:
    mov eax, 0x1337
    ret
