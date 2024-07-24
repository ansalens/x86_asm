; This program shows how to divide numbers where both dividend and divisors are negative numbers.

section .text
global asm_func

asm_func:
    xor eax, eax
    xor edx, edx

    mov ax, -125
    cwd                 ; sign extend AX into DX:AX
    mov cx, -25

    idiv cx


    ret
