- I hit first wall, source code in original x86-64 roadmap github repo is x86-64 meaning __64 bits__ and it's quite different from x86.
- Now I need to figure out a way to translate those sources to x86 assembly.
- Googling around, grabbing Intel IA-32 (x86) reference manual, nasm reference manual...
- Asking chatGPT to translate the x86-64 assembly code to x86.
Assembly code is in `first.asm`, C code is in `first.c`, assembly files should end with `.asm` extension by convention.

# Compiling C code as 32-bit binary
- Because x86 is instruction set for __32 bits__, we need to compile C program as 32 bit:
```
$ gcc first.c -o first -m32
```

# Turning C code into 32-bit assembly
#### Source: https://stackoverflow.com/questions/137038/how-do-you-get-assembler-output-from-c-c-source-in-gcc
- To turn C code into x86 assembly, we can use the following options from `gcc`:
```terminal
$ gcc -c -S first.c
```
- Where `-c` is: compile but don't link, so leave the objects unlinked.
- And `-S` is: stop after compilation stage, output assembly code



# Manually building and linking x86 assembly with `nasm` and `ld`
```terminal
$ nasm -f elf firstassembly.asm -o firstassembly.o
$ ld -m elf_i386 firstassembly.o -o firstassembly
$ ./firstassembly 
$ echo $?
0
```