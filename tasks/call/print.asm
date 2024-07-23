SYSCALL_WRITE equ 4
FD equ 1
SYSCALL_EXIT equ 1

section .data
    str1: db "Hello from assembly", 0x0A
    len1: equ $ -str1

section .text
global _start

_start:
    ; Load str1 and len1 into ECX and EDX respectively
    lea eax, [str1]
    mov ecx, len1

    ; Push those arguments on the stack and call print
    push ecx
    push eax
    call print

    ; Clean up the stack
    add esp, 8
    ;pop eax
    ;pop eax

    xor eax, eax

    ; Must exit properly or receive SEGFAULT
    mov eax, SYSCALL_EXIT
    mov ebx, 0
    int 0x80

print:                          ; print function definition
    push ebp                    ; save the old and set a new ebp
    mov ebp, esp

    ; Prepare a syscall for write
    mov eax, SYSCALL_WRITE
    mov ebx, FD
    mov ecx, [ebp + 8]          ; this is the first argument, the contents of EAX (str1)
    mov edx, [ebp + 12]         ; this is the second argument, the contents of ECX (len1)
    int 0x80

    ; restore old ebp and return to caller
    mov esp, ebp 
    pop ebp
    ret
