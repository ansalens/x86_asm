section .text
    global _start

_start:
    jmp callback

callshell:
    pop esi
    push 0
    push esi

    mov eax, 0xb
    mov ebx, esi    ; argument #1, "/bin/sh"
    mov ecx, esp    ; argument #2, address of args array
    mov edx, 0      ; Argument #3, NULL
    int 0x80

    mov ebx, 0
    mov eax, 1
    int 0x80

callback:
    call callshell      ; call the actual function to do our work
    db "/bin/sh", 0
