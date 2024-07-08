# Hello world in x86 asm

#### Sources:

> https://www.youtube.com/watch?v=HgEGAaYdABA

> https://stackoverflow.com/questions/2353309/assembly-data-code-and-registers


## Theory

- `.data` section is a RW section in our program which will store all variables and other data to be initialized.
- Size of this segment is determined by size of variables in source code of program.
```c
int i = 3;
char a[] = "Hello World";
static int b = 2023;    // Initialized static global variable
void foo (void) {
  static int c = 2023; // Initialized static local variable
}
```
- All these variables, (global vars and local static variables) will be stored in `.data` data segment.

### SYSCALL numbers

- To view all syscall numbers which represent different syscall functions:
```shell
$ find / -name unistd_32.h 2>/dev/null
/usr/include/asm/unistd_32.h
```

- Some syscalls from `unistd_32.h`:
```c
#define __NR_exit 1
#define __NR_fork 2
#define __NR_read 3
#define __NR_write 4
```

## Preparing for write syscall

```asm
	mov eax, 0x4		; use write syscall
	mov ebx, 0x1		; this is file descriptor which is 1 (stdout)
	mov ecx, helloStr	; put address of helloStr into ecx
	mov edx, 0xD		; size of our string plus newline
```

- Looking a `man 2 write` we can figure out what `write` syscall needs.
- Value in __ebx__ is first argument, which is file descriptor to write to.
- Value in __ecx__ is second argument, which is the location of our string in memory.
- Value moved into __edx__ is string's length which is third argument (len).
- Changing it's value to something bigger outputs our string and some junk data:
```shell
Hello, world
��
'hello.asmhelloStr__bss_start_edata_end.symtab.strtab.shstrtab.text.data:
```

## .data segment

```asm
section .data:			                ; data segment
	helloStr: db "Hello, world", 0xA	; add string + \n
    len equ $ -helloStr                 ; gets length of a string
```

- `helloStr` defines a label for memory address at which our string will live.
- `db` means `define byte`
- `0xA` means 10 in decimal which is ASCII for newline char.
- The comma between the string and newline character will just __concatenate__ the two.


## Experimentation with `kill` syscall

- I wrote a simple progam both in asm and in C, that will kill (SIGTERM) the process whose PID is hard-coded into the program.
- I used `man 2 kill` and `man 7 signal` to lookup the details how to call the `kill` syscall.
- Both programs are successfully killing my `watch lsof` command on separate terminal whose PID I identify with `ps aux | grep lsof`.
- I ran both programs with `time` to measure time of execution for both of them:
```bash
$ time ./killer

real    0m0.001s
user    0m0.001s
sys     0m0.000s

$ gcc killer.c -o ckiller
$ time ./ckiller

real    0m0.002s
user    0m0.000s
sys     0m0.002s
```

- __This assembly program is faster than C version of the same program!__
- In reality speed comparison between the two is much more complicated.
- It boils down to, code optimizations in both languages.
