; This demonstrates how calling C external functions work in assembly.
; CDECL calling convention is used to pass arguments to C functions.
extern exit
extern malloc

section .text
global _start

_start:
    push 8                          ; 8 bytes to reserve, first argument
    call malloc
    
    mov [eax], dword 1              ; address of allocated memory is in EAX

    mov [eax + 4], dword 9          ; so EAX has 1 and 9 stored in memory

    mov edx, dword [eax]
    add edx, dword [eax + 4]        ; add stored numbers from EAX into EDX

    push edx                        ; argument to exit, return value

    call exit
