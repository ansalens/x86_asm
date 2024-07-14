; This program shows different data types at play

section .data:
    one_byte: db 255                ; this is a static byte variable with contents of 255
    one_word: dw 65535
    one_dword: dd 4_294_967_295     ; underscores improve readability

section .text
    global asm_func

asm_func:
    ; initialize these registers with 0
    xor eax, eax
    xor edx, edx
    xor ecx, ecx

    mov al, [rel one_byte]
    mov dx, [rel one_word]
    mov ecx, [rel one_dword]
    add eax, edx

    xor eax, eax        ; must reset to 0, because it will overflow
    add eax, ecx
    ret

