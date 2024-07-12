; I don't even get error messages, I just get some warnings when compiling:
;   /usr/bin/ld: bin/problem.o: warning: relocation in read-only section `.text'
;   /usr/bin/ld: warning: creating DT_TEXTREL in a PIE

section .data
    a_byte: db 1

section .text
    global asm_func

asm_func:
    xor eax, eax
    mov al, [a_byte]    ; this works even without [rel a_byte] but why?
    ret
