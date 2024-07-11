section .text
    global asm_func

asm_func:
    mov eax, 8  ; 1000
    and eax, 1  ; 1000 & 0001 = 0
    jz jump1

    mov eax, 0
    ret

jump1:
    mov eax, 0x123
    ret
