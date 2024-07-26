# Using external functions in x86 assembly

- To declare library functions, you need to make them globally accessible using:

```asm
global function
```


- To use external functions like the ones you defined in `lib.asm` you need to use:

```asm
extern function
```

- This `extern` keyword says that the `function` is external and that it's declared outside the current file.
- Then to call these functions you do:

```asm
call function
```

- Remember to exit properly, or face the SEGFAULT.

- To build `lib.asm` and `uselib.asm`:

```sh
$ nasm -f elf uselib.asm -o bin/uselib.o
$ nasm -f elf lib.asm -o bin/lib.o
$ ld bin/uselib.o bin/lib.o -o bin/uselib -m elf_i386
```

## NASM `include`

- NASM has a directive to include source code of another assembly program into current program.
- It takes relative path from the directory it is used in.
- Single object is created for both files, the library and the main program.
- Building `killer.asm`:

```sh
$ nasm -f elf killer.asm -o bin/killer.o
$ ld -m elf_i386 bin/killer.o -o bin/killer
```

- I had big trouble getting this to work. 
- It would correctly get the user inputted pid and display it. But never kill it.
- My thought was that I was not dereferencing the pointer correctly.
- That instead of an actual value, I was supplying memory address of that pointer to the kill syscall.
- But this was not the case, I wasn't converting the user input which is __STRING__ to an integer.
- This loop which is added, converts each string number to it's integer representation, and then calls the kill syscall.


## Calling external C library functions

- Build `malloc.asm` with:

```sh
$ nasm -f elf malloc.asm -o bin/malloc.o
$ gcc -m32 -nostartfiles -o bin/malloc bin/malloc.o
```

- `-nostartfiles` is a flag that will make GCC not link with standard startup files (necessary because of *_start*)
