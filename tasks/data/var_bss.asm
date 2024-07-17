section .bss
    global_var: resd 1               ; global 32-bit variable

section .text
    global _start

_start:
    mov [global_var], dword 10      ; global_var = 10

    mov eax, [global_var]           ; eax = *global_var = 10

    mov edi, 5                      ; edi = 5
    add edi, eax                    ; edi = edi + eax

    mov dword [global_var], 20      ; 'dword' can be specified in destination

    mov eax, dword [global_var]
    add edi, eax                    ; 15+20=35

    ; Return 35 and exit
    mov eax, 1
    mov ebx, edi
    int 0x80
