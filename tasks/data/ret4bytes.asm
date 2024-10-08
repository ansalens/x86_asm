; This program shows how to access an array of bytes within a memory
; using a displacement method. In other words we will be accessing
; our array with index value which we will increment accordingly.

section .data
    bytes_var db 0xA, 0x0b, 0ch, 0xD    ; define byte array 

section .text
    global asm_func

asm_func:
    mov eax, -1             ; initialize with -1 (0xFFFFFFFF)
    mov al, [bytes_var]     ; al = bytes_var[0];
    shl eax, 8

    mov al, [bytes_var + 1] ; al has now second element
    shl eax, 8

    mov al, bytes_var[2]    ; AL now has third element
    shl eax, 8

    mov al, [bytes_var + 3] ; AL has now the last, fourth element
    ret


