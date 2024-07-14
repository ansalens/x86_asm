; This program is similar to hello.asm from helloworld task
; This time we can understand deeper what's happening.

global _start

; Defining directives to assembler, basically defining constants
SYSCALL_WRITE equ 4
SYSCALL_EXIT equ 1
STDOUT equ 1

section .data
    bytes: db 'O', 'K', 10          ; 'OK\n' is this an char array?
    LEN equ $ - bytes               ; get length of label 'bytes' 


section .text
_start:
    ; print label on screen
    mov eax, SYSCALL_WRITE
    mov edi, STDOUT                 ; we can use edi instead od ebx
    mov esi, bytes                  ; we can use esi instead of ecx
    mov edx, LEN

    int 0x80

    ; exit gracefully
    mov eax, SYSCALL_EXIT
    xor ebx, ebx
    int 0x80

