section .text

global _start

_start:
    push 0x00
    push shell

    ; execute /bin/sh
    mov eax, 0xb        ; syscall number for execve
    mov ebx, shell      ; memory location for /bin/sh
    mov ecx, esp        ; memory reference to /bin/sh
    mov edx, 0x00       ; NULL pointer

    int 0x80

    mov eax, 1
    xor ebx, ebx

    int 0x80

section .data
    shell: db "/bin/sh", 0x00
