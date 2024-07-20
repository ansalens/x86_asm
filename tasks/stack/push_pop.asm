section .text
    global asm_func

asm_func:
    mov ax, 0xf00d              ; push a word on the stack
    push ax
    mov eax, 200_000_000_0      ; push a double on the stack
    push eax
    push word 1000              ; push an immediate on the stack

    pop ax                      ; pop an immediate
    pop eax                     ; pop a double
    xor eax, eax                ; clear the EAX
    pop ax                      ; pop the word (0xf00d)
    ret
