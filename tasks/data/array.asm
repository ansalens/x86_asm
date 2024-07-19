LEN equ 10

section .bss
    int_array: resd LEN

section .text
    global asm_func

asm_func:
    lea ebx, [int_array]
    xor ecx, ecx
    xor eax, eax

    ; Populate an array with logically shifted numbers by 1 to the left
loop:
    mov al, cl
    shl al, 1

    mov [ebx + ecx * 4], eax
    inc cl
    cmp cl, LEN
    jnz loop

    xor eax, eax
    xor ecx, ecx

    ; Sum all elements from an array into EAX
sum:
    add eax, [ebx + ecx * 4]
    inc cl
    cmp cl, LEN
    jnz sum

    ; TO-DO: Print all elements of an array to the screen
    ret
