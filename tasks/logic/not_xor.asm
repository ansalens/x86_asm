; This program shows NOT and XOR bitwise operations in action

section .text
    global asm_func

asm_func:
    mov al, 111111b     ; dec 63
    mov dl, 010111b     ; dec 23

    xor al, dl          ; dec 40
    cmp al, 40
    je equal            ; jump if al == 40

    jne not_equal

not_equal:              ; not taken
    mov eax, 1
    ret

equal:                      ; taken
    mov al, 01111111b       ; dec 255, MSB is just a sign
    mov dl, 255
    xor al, dl              ; AL = 0
    not al                  ; AL = 255
    inc al                  ; overflowed the AL, AL is now 0
    jo overflow

    jmp no_overflow         ; can be commented out, it goes to no_overflow

no_overflow:
    mov eax, 2
    ret

overflow:
    mov eax, 0x1337
    ret
