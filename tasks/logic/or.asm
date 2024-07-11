section .text
    global asm_func

asm_func:
    mov al, 7   ; 0111
    mov cl, 8   ; 1000
    or al, cl   ; 1111
    jnz not_zero

    mov eax, 0
    ret

not_zero:
    mov eax, 0xfefe
    ret
