section .bss
    pid resb 10                 ; reserve 10 bytes for the pid (PID and a null terminator)

section .text
get_pid:                        ; get the PID from the user
    mov eax, 3                  ; read syscall
    mov ebx, 0                  ; stdin
    lea ecx, [pid]              ; load the address of pid into ECX, this is our pider
    mov edx, 10                 ; this is pid length, 10 bytes to ensure we can read enough
    int 80h
    ret

print_pid:                      ; prints the PID that user entered
    mov eax, 4                  ; write syscall
    mov ebx, 1                  ; stdout
    lea ecx, [pid]              ; address of PID variable
    mov edx, 10                 ; length of the pid
    int 80h
    ret

kill_pid:                       ; kills the process with PID number
    lea esi, [pid]
    xor eax, eax
    xor ebx, ebx
    mov ecx, 10                 ; Base 10

convert_loop:                   ; convert ASCII PID to integer
    lodsb                       ; Load byte from [esi] into al, and increment esi
    cmp al, 10                  ; Check for newline character
    je conversion_done          ; If newline, we're done
    sub al, '0'                 ; Convert ASCII to number
    imul ebx, ebx, 10           ; Multiply ebx by 10
    add ebx, eax                ; Add to ebx
    jmp convert_loop

conversion_done:                ; ebx now contains the PID as an integer
    mov eax, 37                 ; kill syscall
    mov ecx, 9                  ; SIGKILL
    int 80h
    ret

exit:                           ; exit gracefully
    mov eax, 1
    xor ebx, ebx
    int 80h
    ret
