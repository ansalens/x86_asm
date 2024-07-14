; This program shows how to create an array of dword elements that are initialized to 1
; and how to populate elements by specifying correct offset from EBX

section .text
    global _start

_start:
    mov ebx, words_table        ; move memory location of an array into ebx
    mov dword [ebx], 400        ; move number 400 to first element of an array

    mov dword [ebx + 4], 500    ; move number 500 to second element of an array
    mov dword [ebx + 8], 600    ; move number 600 to third element...
    cmp dword [ebx + 8], 600    ; compare if the move was successful
    je equal

    mov eax, 1
    mov ebx, -1
    int 0x80

equal:                          ; should jump here and check if fourth element is initialized to 1
    cmp dword [ebx + 12], 1
    je initialized

    mov eax, 1
    mov ebx, 2
    int 0x80

initialized:                    ; should return 0, because other elements really are initialized to 1
    mov eax, 1
    mov ebx, 0
    int 0x80


section .data
    words_table times 10 dd 1       ; here we define an array with 10 elements each initialized to 1
