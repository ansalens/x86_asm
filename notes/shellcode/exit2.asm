section text
    global _start

_start:
    xor eax, eax        ; zero out EAX
    mov al, 1
    int 0x80
