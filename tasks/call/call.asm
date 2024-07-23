section .text
global asm_func

asm_func:
    xor eax, eax
    mov eax, 150
    mov edx, 81

    call sub_reg

    ret


sub_reg:
    ;mov eax, ecx
    sub eax, edx
    ret
