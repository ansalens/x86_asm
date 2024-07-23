# Statically compiled programs on Linux

- Program execution begins in Linux kernel.
- Some of the functions from __exec family__ calls __sys_execve__ syscall.
- Kernel knows a lot of binary formats and loads your program's binary into RAM.
- From here it tries these formats when running your program, until it finds the correct one.
- It reads __ELF__ header, and looks for `__PT_INTERP__` segment.
- `PT_INTERP` basically tells if program is compiled statically or dynamically.
- If there's no `PT_INTERP`, Kernel knows that the program is __static__.
- From here Kernel maps program's segments into memory (sets up the stack with arguments and env variables).

## Function `main` is not an entry point in your program

- It's actually __*_start*__ symbol.
- Program linker __ld__ looks for `_start` in any and all programs.
- Build the `example.asm` program with then read `ELF` header:

```asm
$ nasm -f elf example.asm -o example.o
$ ld -m elf_i386 example.asm -o example
$ readelf -h example
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF32
--- snip ---
  Entry point address:               0x8049000
--- snip ---
```

- Then disassemble the binary image:

```asm
$ objdump -d ./bin/example
08049000 <_start>:
 8049000:       b8 01 00 00 00          mov    $0x1,%eax
 8049005:       bb 00 00 00 00          mov    $0x0,%ebx
 804900a:       cd 80                   int    $0x80
 ```
 
- Program entry point can be overwritten with `--entry` flag.

## Entry point in C programs

- Compile the following `entry.c` with:

```sh
$ gcc -c entry.c -o bin/entry.o -m32
$ ld -m elf_i386 bin/entry.o -o bin/entry
ld: warning: cannot find entry symbol _start; defaulting to 08049000
```

- Now compile it with `-static` flag:

```sh
$ gcc entry.c -o bin/entry -static -m32
$ ./bin/entry
$ echo $?
0
```

- This time it works. And it does because, now it's compiled with additional objects and `libc.a` static library.
- Decompile it again and see something else in `_start`:

```sh
$ objdump -d ./bin/entry | grep -A15 "_start"
08049670 <_start>:
 8049670:       31 ed                   xor    %ebp,%ebp
 8049672:       5e                      pop    %esi
 8049673:       89 e1                   mov    %esp,%ecx
 8049675:       83 e4 f0                and    $0xfffffff0,%esp
 8049678:       50                      push   %eax
 8049679:       54                      push   %esp
 804967a:       52                      push   %edx
 804967b:       e8 19 00 00 00          call   8049699 <_start+0x29>
 ```

- It's basically stuff from `__libc_start_main` from GNU C library.
- It does a lot of things, among them is calling the actual `main` function:
1. Figure out env variables on stack
2. ...
3. ...
4. ....
5. Initialize libc...
6. ...
7. ...
8. Call `main(argc, argv, envp)`
9. Call exit with return code from `main`


---

Resource: 
> https://eli.thegreenplace.net/2012/08/13/how-statically-linked-programs-run-on-linux
