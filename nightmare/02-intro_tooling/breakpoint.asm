section .text
global _start

_start:
    xor eax, eax
    int 0x3             ; place a software breakpoint
    
    mov eax, 1
    xor ebx, ebx
    int 0x80
