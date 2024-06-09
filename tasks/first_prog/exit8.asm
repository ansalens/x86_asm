section .text
    global _start

_start:
    mov eax, 1      ; prepare for exit function
    mov ebx, 8      ; return code will be 8
    int 0x80        ; make a syscall
