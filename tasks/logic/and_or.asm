; This program shows the use of bitwise AND and OR operations

section .text
    global asm_func

asm_func:
    xor eax, eax    ; mov eax, 0
    mov al, 0111b   ; mov al, 7
    mov cl, 1001b   ; mov cl, 9
    and al, cl      ; al = 0001

    mov cl, 1000b   ; mov cl, 8
    or al, cl       ; al = 1001 = 9
    cmp al, 9
    je equal

    xor ecx, ecx    ; clear out ECX
    ret

equal:
    mov eax, 0xbeef
    ret
