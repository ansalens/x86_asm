; This program calls another program (library).

extern hello
extern exit

section .text
global _start

_start:
    call hello
    call exit
