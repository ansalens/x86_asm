; This program shows how to get any element that was pushed before
; using an offset to ESP register.

section .text
    global asm_func

asm_func:
    ; pushing a word onto stack
    xor eax, eax
    sub esp, 2
    mov ax, 0xffff
    mov [esp], ax


    ; pushing a double word onto stack
    sub esp, 4
    xor eax, eax
    mov eax, 6_000_000
    mov [esp], eax

    ; pushing an immediate word
    ; word keyword is necessary, it doesn't know how to treat an immediate
    sub esp, 2
    mov word [esp], 0xf00d

    ; pushing another word onto stack
    sub esp, 2
    mov cx, 0100_0101_0100_0001b
    mov [esp], cx

    xor eax, eax
    mov ax, [esp]

    ; getting the first element (dword)
    ; two words and dword were pushed after first push, so that makes 8 our offset
    xor ax, [esp + 8]

    ; whatever gets pushed onto stack must be popped of from stack
    ; you need to pop so that EIP knows how to return to caller
    ; leaving just one pop commented results in segfault
    ;pop dx
    ;pop dx
    ;pop edx
    ;pop dx

    ; these 4 pop instructions are equivalent to this
    add esp, 10

    ret
