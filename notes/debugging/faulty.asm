section .text
    global asm_func

section .data
    bytes_array db 1,2,3,4

asm_func:
    xor eax, eax
    mov eax, [bytes_array]
    ret
