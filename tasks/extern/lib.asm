; This is a library. It will be used to generate another asm object file.
; It will then be linked with another object file to form a final executable.
global exit
global hello

section .data
    msg: db "Hello from lib.asm", 0x0A
    len: equ $-msg

section .text
hello:
    mov eax, 4
    mov ebx, 1
    lea ecx, [msg]
    mov edx, len
    int 0x80

exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80
