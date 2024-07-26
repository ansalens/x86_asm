; Includes a library using NASM's include directive.
; No need for using global keyword.
; This program get's a PID from user input and then kills it.

%include "libkiller.asm"

global _start
_start:
    call get_pid
    ;call print_pid
    call kill_pid
    call exit
