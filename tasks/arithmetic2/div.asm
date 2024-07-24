; This program shows unsigned division in both scenarios.

section .text
global asm_func

asm_func:
    xor eax, eax
    xor ecx, ecx
    xor edx, edx

    ; scenario 2, dividend stored in DX and AX
    ; quotient (result) is AX = 1337, remainder is DX = 0
    mov ax, 33425
    mov cx, 25
    div cx
    add ax, dx

    ; scenario 1
    ; result is AL = 191, remainder is AH = 0
    mov cl, 7
    div cl
    add al, ah

    ret
