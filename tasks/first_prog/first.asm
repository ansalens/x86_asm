section .text			; This is text section, where our code lives
    global _start

_start:
    mov eax, 1     ; syscall number for exit
    xor ebx, ebx   ; return code 0
    int 0x80       ; invoke syscall
