; This program shows that shifting bits to the right by 2
; is the same as dividing the operand with 4

section .text
    global asm_func

asm_func:
    mov al, 0b11110000  ; 240
    shr al, 2           ; 0b00111100 = 60
    cmp al, 60
    je equal

    xor eax, eax
    ret

equal:
    mov eax, 0x1337
    ret
