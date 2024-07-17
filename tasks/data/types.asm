; This program shows different data types at play

; data will hold initialized static global variables
section .data:
    one_byte: db 255                ; this is a static byte variable with contents of 255
    one_word: dw 65535
    one_dword: dd 4_294_967_295     ; underscores improve readability

section .text
    global asm_func

asm_func:
    xor eax, eax
    xor edx, edx
    xor ecx, ecx

    mov al, [one_byte]
    mov dx, [one_word]
    mov ecx, [one_dword]
    add eax, edx                    ; 65535+255

    xor eax, eax                    ; must be set to 0, otherwise it will overflow
    add eax, ecx                    ; EAX has maximum 32bit value
    ret
