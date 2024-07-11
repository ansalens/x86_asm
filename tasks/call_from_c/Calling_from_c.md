## Prelude

If we want to know what are the contents of a register, we can write our assembly program
which will be called from our C program. Our assembly program will be called like a library.

It won't contain __\_start__ entry point, because we will be calling it from C.
It will contain a globally declared function which will *`mov`* an integer into __EAX__ register.
Then it will `ret` control to function caller.

## `caller.c`

- This program in C will call `asm_func` from our assembly program and store the result as __UNSIGNED__ 32 bit integer in `result` variable.
- From there it will print this result in 4 different formats (SGN, decimal, hex and bin).

## Compiling and linking things up

*NOTICE*
- There is slight variation in our assembly programs...
- `ret_int.asm` will return 2 billion to the caller, while `ret_neg_int.asm` will return __-1__ to the caller.

---

- Assemble the programs:
```bash
$ nasm -f elf ret_int.asm -o bin/obj1.o
$ nasm -f elf ret_neg_int.asm -o bin/obj2.o
```

- Link them together with `caller.c`:
```bash
$ gcc -m32 caller.c bin/obj1.o -o bin/caller1
$ gcc -m32 caller.c bin/obj2.o -o bin/caller2
```

- Remember that `-m32` flag is important for compiling 32 bit binaries, without it I get:
```bash
$ gcc caller.c bin/obj1.o -o bin/caller1
/usr/bin/ld: i386 architecture of input file 'bin/obj1.o' is incompatible with i386:x86-64 output
collect2: error: ld returned 1 exit status
```

# Running both programs
```bash
$ ./bin/caller1 
DEC: 2000000000
HEX: 77359400
```

- Running second program yields something interesting:
```bash
$ ./bin/caller2
DEC: 4294967295
HEX: ffffffff
BIN: 11111111 11111111 11111111 11111111
```

- Because `ret_neg_int.asm` returned __-1__ from __EAX__ register, and in C we defined return result to be __UNSIGNED__, this will actually print the highest __SIGNED__ 32-bit integer.