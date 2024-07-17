WRITE equ 4
STDOUT equ 1

section .bss
    int_array: resb 50

section .text
    global _start

_start:
    ; load the start address (base) of an array in ESI
    lea esi, [int_array] 

    ; Move around characters into ESI, 'Hello\n'
    mov [esi], byte 'H'
    mov [esi + 1], byte 'e'
    mov [esi + 2], byte 'l'
    mov [esi + 3], byte 'l'
    mov [esi + 4], byte 'o'
    mov [esi + 5], byte 10

    ; Prepare write syscall
    mov eax, WRITE
    mov ebx, STDOUT
    mov ecx, esi
    mov edx, 6
    int 0x80


    ; Move around some more characters into ESI, this time at a different offset
    ; 'Cool stuff\n'
    mov [esi + 50], byte 'C'
    mov [esi + 51], byte 'o'
    mov [esi + 52], byte 'o'
    mov [esi + 53], byte 'l'
    mov [esi + 54], byte ' '
    mov [esi + 55], byte 's'
    mov [esi + 56], byte 't'
    mov [esi + 57], byte 'u'
    mov [esi + 58], byte 'f'
    mov [esi + 59], byte 'f'
    mov [esi + 60], byte 0xA

    ; Prepare write syscall, write from the offset position
    mov eax, WRITE
    mov ebx, STDOUT
    lea ecx, [esi + 50]
    mov edx, 11
    int 0x80

    ; Return 0
    mov eax, 1
    xor ebx, ebx
    int 0x80


