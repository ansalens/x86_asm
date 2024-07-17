; This program shows how to use scaled indexed addressing mode

section .data
    array_words: dw 0x0f, 0x0e, 0x0d, 0x0c

section .text
    global asm_func

asm_func:
    xor eax, eax
    xor edx, edx
    lea ebx, [array_words]      ; load address of an array in EBX

    ; Here we use AX (16 bit) as destination register
    ; And we use EBX as base register and EDX times 2
    ; this gets an effective address of first element, because EDX = 0
    ; We multiply by two, because word is 2 bytes
    mov ax, [ebx + edx * 2]
    inc edx
    shl eax, 16

    mov ax, [ebx + edx * 2]
    inc edx
    shl eax, 16

    mov ax, [ebx + edx * 2]
    inc edx
    shl eax, 16

    mov ax, [ebx + edx * 2]

    ret


