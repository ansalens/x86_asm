; This program shows how to perform division if dividend is positive and divisor is negative number.
section .text
global asm_func

asm_func:
    xor eax, eax
    xor edx, edx
    
    mov ax, 60          ; unsigned dividend
    mov cx, -2          ; signed divisor

    movsx ecx, cx       ; move cx to ecx with sign extension
    ;movzx eax, ax       ; move ax to eax with zero extension

    cdq                 ; sign extend eax into EDX:EAX
    idiv ecx

    ret
