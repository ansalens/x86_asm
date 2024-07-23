; This program will demonstrate how manipulating local stack variables works
section .text
global asm_func

asm_func:
    ; reserve a space for local variables on stack (4 * word = 16)
    sub esp, 16

    mov dword [esp], 1              ; x = 1
    mov dword [esp + 4], 9          ; y = 9
    mov dword [esp + 8], 109        ; z = 109
    mov dword [esp + 12], 1009      ; t = 1009

    xor eax, eax
    mov eax, [esp + 8]              ; eax = z
    sub eax, [esp + 4]              ; eax = eax - y = 100
    mov [esp + 8], eax              ; z = eax

    sub eax, [esp]                  ; eax = eax - x = 99
    imul eax, [esp + 4]             ; eax = eax * y

    mov [esp], eax                  ; x = eax
    add eax, [esp + 4]              ; eax = eax + y = 900

    mov dword [esp + 12], 437       ; t = 437
    add eax, [esp + 12]             ; eax = eax + t



    ; if you forget to pop the stack or ret you get segfault
    add esp, 16
    ret
