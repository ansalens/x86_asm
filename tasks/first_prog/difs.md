# Differences between x86-64 and x86 (first.asm)

```asm
section .text
	global _start
```

- This is beginning of our program.
- `.text` section is where our program is stored at.
- This makes it so that the __label__ `_start` is easily found outside the executable by OS.
	- OS may call it when needed.

```asm
_start:
    mov eax, 1     ; syscall number for exit
    xor ebx, ebx   ; return code 0
    int 0x80       ; invoke syscall, call exit with ebx
```

- This is __entry point__ to our program.
- Here we use register __eax__ instead of __rax__.
- Syscall number for __exit__ is 1 in x86.
- Register __ebx__ is the register for *exit code*
- We *xor* register ebx with itself, so that it contains 0.
- Making a syscall is with `int 0x80`, which will look into eax register to decide which function to call.

## Exit code experimentation
- You can return any int exit code in range 0-255.
- If you try to return value that is above the range, like 257 it will return 1.
- If you try to return negative integer like -2, it will return 254.