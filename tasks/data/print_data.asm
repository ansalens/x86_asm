; This program is similar to hello.asm from helloworld task

; Defining directives to assembler, basically defining constants
SYSCALL_WRITE equ 4
SYSCALL_EXIT equ 1
STDOUT equ 1

section .data
    bytes: db 'O', 'K', 10          ; 'OK\n' character array 
    LEN equ $ -bytes                ; get length of label 'bytes' 

section .text
global _start

_start:
    ; print label on screen
    mov eax, SYSCALL_WRITE
    mov ebx, STDOUT
    mov ecx, bytes
    mov edx, LEN

    int 0x80

    ; exit gracefully
    mov eax, SYSCALL_EXIT
    xor ebx, ebx
    int 0x80
