section .text
    global _start

_start:
    xor eax, eax
    push eax
    push 0x68732f6e     ;n/sh
    push 0x69622f2f     ;//bi 

    xor edx, edx        ; Third arg: NULL
    xor ecx, ecx        ; Second arg: NULL
    mov ebx, esp        ; First arg: "/bin/sh"
    mov al, 0xb
    int 0x80
