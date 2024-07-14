section .text
    global asm_func

asm_func:
    xor eax, eax
    mov eax, 1337h
    ret


section .data
    array1 dw 250, 350, 450, 550, 650

