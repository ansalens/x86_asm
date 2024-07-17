LEN equ 10

section .bss
    int_array: resd LEN

section .text
    global asm_func

asm_func:
    lea ebx, [int_array]
    xor ecx, ecx
    xor eax, eax

    ; Populate an array 
loop:
    mov al, cl
    shl al, 1

    mov [ebx + ecx * 4], eax
    inc cl
    cmp cl, LEN                 ; does it count from 0 or from 1? Is it LEN or LEN-1?
    jnz loop

    xor eax, eax
    xor ecx, ecx

sum:
    add eax, [ebx + ecx * 4]
    inc cl
    cmp cl, LEN-1
    jnz sum

    mov esi, int_array
    xor ecx, ecx
    xor eax, eax
    xor ebx, ebx
    xor edx, edx
    xor edi, edi
    mov eax, 4
    mov ebx, 1
    mov edx, 3

display:
    mov dword ecx, esi
    int 0x80

    inc edi
    cmp edi, LEN-1
    jnz display

    ret
