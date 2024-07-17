; This program shows how to define global variables with different types
; and then how to increment/decrement them throughout the program

section .bss
    syscall: resw 1
    code: resb 1

section .text
    global _start

_start:
    mov word [syscall], 0       ; syscall = 0
    inc word [syscall]          ; syscall++

    mov ax, [syscall]           ; we use AX because 'syscall' var is a word

    mov byte [code], 1          ; code = 1
    dec byte [code]             ; code--
    dec byte [code]             ; code--
    mov bl, [code]              ; we use BL because 'code' is a byte

    int 0x80
