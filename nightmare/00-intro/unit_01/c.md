# Unit 1: C programming and compilation

## Multi Step Compilation Process

- Compiling just `hello.c` without the `world.c` outputs:

```sh
$ gcc hello.c -o hello
/usr/bin/ld: /tmp/cclXqE8Y.o: in function `main':
hello.c:(.text+0x30): undefined reference to `world'
collect2: error: ld returned 1 exit status
```

- This means compilation was a success, while linking was failure.
- `ld` GNU linker doesn't know what `world` is and therefore needs additional code for that function.
- To be sure, check to see if you can generate object file (compile):

```sh
$ gcc -c hello.c -o hello.o
$ echo $?
0
```

- Viewing this object file with `readelf` gives a clue what this file is:

```sh
$ readelf -h hello.o
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              REL (Relocatable file)
```

- It's __REL (Relocatable file)__.
- Trying to run this file I get:

```sh
$ ./hello.o
-bash: ./hello.o: cannot execute binary file: Exec format error
```

- That's because this isn't a complete executable, and needs to pass linking process.
- Compiling and linking both object files `hello.o` and `world.o` gets us the proper executable:

```sh
$ gcc hello.o world.o -o hello -v
Using built-in specs.
COLLECT_GCC=gcc
-- snip --
COLLECT_LTO_WRAPPER=/usr/lib/gcc/x86_64-pc-linux-gnu/14.1.1/lto-wrapper
 /usr/lib/gcc/x86_64-pc-linux-gnu/14.1.1/collect2 -plugin /usr/lib/gcc/x86_64-pc-linux-gnu/14.1.1/liblto_plugin.so  ....
$ ./hello
Hello world!
```

- Passing `-v` to `gcc` shows us that there are more things happening in the background.
- `collect2` is just another name for `ld` or GNU linker.
- There are also present other 64 bit object files that all come together to form one final executable, that is our program.

## Breaking down compilation even further

- If you try to link both object files directly like this:

```sh
$ ld hello.o world.o -o hello
ld: warning: cannot find entry symbol _start; defaulting to 0000000000401000
ld: hello.o: in function `hello':
hello.c:(.text+0x14): undefined reference to `printf'
ld: world.o: in function `world':
world.c:(.text+0xf): undefined reference to `puts'
```

- You come against two problems:
1. Linker doesn't know where `_start` entry is in the program
2. Linker doesn't know what `printf` and `puts` are

- To immediately solve second problem you add `-lc` to the `gcc`, which will add the C library.
- Now to solve first problem with the help of output from `gcc -v` command above we may do the following:

```sh
$ ld -lc -o hello /usr/lib/crt1.o -lc hello.o world.o
$ echo $?
0
```

- Now this looks like it, but when we try to execute this file:

```sh
$ ./hello
-bash: ./hello: cannot execute: required file not found
```

- Some systems may get a clearer error than what I've got here:

```sh
aviv@si485h-clone0:~/tmp$ ld -lc -o hello /usr/lib/x86_64-linux-gnu/crt1.o -lc hello.o world.o 
/usr/lib/x86_64-linux-gnu/libc_nonshared.a(elf-init.oS): In function `__libc_csu_init':
(.text+0x2d): undefined reference to `_init'
```

- Let's try to solve this problem by including `crti.o` which includes the `_init`:

```sh
$ ld -lc -o hello /usr/lib/crt1.o /usr/lib/crti.o -lc hello.o world.o
```

- Again when trying to execute the program, I get the same error message on my system, but here's a more clear message:

```sh
/usr/lib/x86_64-linux-gnu/crt1.o: In function `_start':
(.text+0x12): undefined reference to `__libc_csu_fini'
(.text+0x19): undefined reference to `__libc_csu_init'
```

- This is solved by moving `-lc` switch later in the command:

```sh
$ ld -o hello /usr/lib/crt1.o -lc /usr/lib/crti.o -lc hello.o world.o
```

- But that's not the end, we are missing dynamic loading which is done by dynamic linker:

```sh
$ ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 /usr/lib/crt1.o -lc /usr/lib/crti.o -o hello hello.o world.o
$ ./hello
Segmentation fault (core dumped)
```

- The last thing we need is the code that will end assembly, which is in `/usr/lib/crtn.o`
- Finally, this is what `ld` does in the background when linking our programs:

```sh
$ ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 /usr/lib/crt1.o -lc /usr/lib/crti.o -o hello hello.o world.o /usr/lib/crtn.o
$ ./hello
Hello world!
```

## 32-bit compilation

- There are some flags I will include in compilation to disable security features and compile into 32-bit elf:
- I've created a bash function which I've put inside my `.bashrc`:

```sh
function gcc32() {
     gcc "$1".c -m32 -fno-stack-protector -z execstack -no-pie -o "bin/$1"
}
```

## Library functions vs system calls

- System call (syscall) is a __mechanism by which a programmer can access some feature of an operating system.__
- These features which are available only through syscalls are:
1. Input/output: reading and writing from devices, network, peripherals
2. Memory management: maintaining memory for programs, virtual memory...
3. Program execution: loading and unloading programs which will be executed by the CPU

### Tracing function and system calls

- Two tools:
1. `ltrace` - traces library calls
2. `strace` - traces system calls

- They are both good for seeing how the program works under the hood:

```sh
$ ltrace ./hello > /dev/null
printf("Hello")                                                                                                      = 5
puts(" world!")                                                                                                      = 8
+++ exited (status 0) +++
```

- `printf` and `puts` are both library calls.

```sh
$ strace ./hello > /dev/null
execve("./hello", ["./hello"], 0x7ffd57741260 /* 53 vars */) = 0
--- snip --
write(1, "Hello world!\n", 13)          = 13
exit_group(0)                           = ?
+++ exited with 0 +++
```

- We can see a bunch of syscalls, `execve` which executes our program and bunch of other syscalls.
- At the end we see `write` syscall which actually prints things on screen.
- *C library functions are just friendly way of interacting with syscalls.*

## Using syscalls instead of library functions

- Consider `hellosyscall.c` which uses `write` library wrapper for the actual `write` syscall.

```sh
$ ltrace ./hellosyscall > /dev/null
__libc_start_main(0x804907d, 1, 0xffadd174, 0 <unfinished ...>
write(1, "Hello world!\n", 13)                                                                                       = 13
+++ exited (status 0) +++
$ strace ./hellosyscall > /dev/null
-- snip --
write(1, "Hello world!\n", 13)          = 13
exit_group(0)                           = ?
```

- That's why `write` is still shown in `ltrace`, because it's not real syscall it just appears to be.

## Numeric Data Types and Sign-ness

### Basic numeric types

- Analyze `datatypes.c` program.
- Notice `long` and `int` data types are the same in size (4 bytes).
- Only `long long` is 8 bytes.
- See `twos-comp.c`, `signess.c` and `unsigned.c` for concrete examples.

## Pointers and memory references

- Pointer is a variable that contains a memory address of another variable.
- In other words it's just a variable that contains a number.
- `int *p` declares integer pointer.
- `*p` uses dereference operation, it follows the pointer to the memory address referenced by p.
- `&p` returns the address of variable `p` in memory.

- Look at `reference.c` for some pointer action.

## Randomization of memory

- ASLR (Address Space Layer Randomization) is a security mechanism that will randomize address space on every program execution.
- See ASLR in action:

```sh
$ ./bin/reference
a = 20, &a = 0xfff0c28c
b = 30, &b = 0xfff0c288
p = 0xfff0c288, &p = 0xfff0c284, *p = 30
$ ./bin/reference
a = 20, &a = 0xffe5cf2c
b = 30, &b = 0xffe5cf28
p = 0xffe5cf28, &p = 0xffe5cf24, *p = 30
```

- To disable it:

```sh
$ cat /proc/sys/kernel/randomize_va_space
2
$ echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
```

- Notice the difference:

```sh
$ ./bin/reference
a = 20, &a = 0xffffd07c
b = 30, &b = 0xffffd078
p = 0xffffd078, &p = 0xffffd074, *p = 30
$ ./bin/reference
a = 20, &a = 0xffffd07c
b = 30, &b = 0xffffd078
p = 0xffffd078, &p = 0xffffd074, *p = 30
```

- This will make exploitation easier, but don't forget that remote machines __probably have ASLR enabled by default__.

## Arrays and strings

### Array Values and Pointers are the same thing!

- *Fact:* An array value is the same as a pointer.
- __An array is adjacent memory block that holds a sequence of similar data.__
- An array itself references the __memory address of the first index of that array (also called base address).__
- Thus, __an array is actually just a pointer.__
- But even though array and pointers are __memory references__, they are __not declared the same way__.
- Meaning that, an array must reference data it holds in memory, but pointer can reference any address in memory including an array.

- Have a look at program output from `array.c`:

```sh
$ ./bin/arrays
array = 0xffbdbd94, p = 0xffbdbd94
array[0] = 10
array[1] = 11
array[2] = 12
array[3] = 13
array[4] = 1337
```

- `array` and `p` both point to the same thing, and that thing is the first element of an `array`!

- We used to set `1337` to the last element of an array with `p[4] = 1337;`.
- This means that `p[i]` is the same as `*(p+i)`, which just adds index to the base of an `array`!

- Look at the program output of `p_array.c`:

```sh
$ ./bin/p_arrays
array = 0xffe59ae4, p = 0xffe59ae4
array+0=0xffe59ae4, *(array+0) = 11
array+1=0xffe59ae8, *(array+1) = 12
array+2=0xffe59aec, *(array+2) = 13
array+3=0xffe59af0, *(array+3) = 14
array+4=0xffe59af4, *(array+4) = 1337
```

### Pointer arithmetic

- Look closely at the previous output, and you can see that each increment in memory is 4.
- That's because integer data type is 4 bytes wide.
- Computer automatically increments each address it is referencing by the size of the data type that is stored in that array.
- Look at the output of `pointer_arithmetic.c`:

```sh
$ ./bin/pointer_arithmetic
# int = 4 bytes
a+0=0xff81e9d0, *(a+0) = 11
a+1=0xff81e9d4, *(a+1) = 12
a+2=0xff81e9d8, *(a+2) = 13
a+3=0xff81e9dc, *(a+3) = 14
a+4=0xff81e9e0, *(a+4) = 15

# short = 2 bytes
b+0 = 0xff81e9c6, *(b+0) = 11
b+1 = 0xff81e9c8, *(b+1) = 12
b+2 = 0xff81e9ca, *(b+2) = 13
b+3 = 0xff81e9cc, *(b+3) = 14
b+4 = 0xff81e9ce, *(b+4) = 15

# char = 1 byte
c+0=0xff81e9c1, (c+0) = 11
c+1=0xff81e9c2, (c+1) = 12
c+2=0xff81e9c3, (c+2) = 13
c+3=0xff81e9c4, (c+3) = 14
c+4=0xff81e9c5, (c+4) = 15
```

### Strings

- *String is just an array of characters that is NULL terminated at the end.*
- They can be declared just like a char array (`chararray.c`) or can be declared with double quotes (`string.c`).
- Declaring strings with double quotes creates a char array in the background.
- However we declare them, we must declare a variable that is an array type or a pointer type.
- Leveraging the fact that all strings end with `\0` (NULL, false) makes using them with pointers easier (`string_iterate.c`).

## Program memory layout

### Cowboys and Endian-s

- We read numbers from left to right, so number 150500 is one hundred and fifty thousand, five hundred.
- Where __MSB (Most Significant Byte)__ is represented is called __endian-ness.__
- Most computers, read data from right to left, which is called __little endian.__
    - This is when __LSB (Least Significant Byte)__ comes first.
- __Big endian__ is when __MSB__ comes first, the opposite of little endian.
- Consider the output of program `endian.c` where `0xdeadbeef` is written in reverse:

```sh
$ ./bin/endian
p[0] = 0xef
p[1] = 0xbe
p[2] = 0xad
p[3] = 0xde
```

### Stack, Heap, Data, BSS segments

- Virtual address space allows the program to treat __the entire available memory in ordered fashion (from highest to lowest address).__
- In reality it's all stored randomly on RAM.
- `.text` segment is stored at the beginning of the address space, far from the heap and stack to prevent them from overflowing into it.
- It's also shared in memory, so single copy is available for text editors, gcc...
- `.data` segment contains initialized __global__ variables and __static__ variables.
- This segment has RO area and RW area. RO is where literal constants dwell.
- `.bss` segment contains all __global__ variables and __static__ variables that are uninitialized in source code (in reality they are initialized to 0).
- `.stack` segment contains program's stack, and the stack frame contains at minimum the return address (if the function has no variables).
- Each call to a function reserves a space on the stack for it's variables (new stack frame), that is how recursive functions work.
- `.heap` segment contains dynamically allocated memory and is managed with functions `malloc`, `realloc` and `free`.
- Heap area is shared by all shared libraries and dynamically loaded modules.
- Use the `size` command to measure the size of `.text`, `.bss` and `.data` segments of a program:

```sh
$ size bin/hello
   text    data     bss     dec     hex filename
   1508     592       8    2108     83c bin/hello
```

- More about virtual memory, program segments is already done in ![linux_memory](../../../tasks/data/linux_memory.md).
- Key thing is to remember that __program's data along with it's code__ is stored in memory __together__!
- Look the following output of `mem_layout.c` and see for yourself:

```sh
$ ./bin/mem_layout
(reserved) envp = 0xff9d6c2c
(stack) &a = 0xff9d6b34
(stack) stack_str = 0xff9d6b2e
(heap) heap_str = 0x085a11a0
(bss) bss_int = 0x0804c020
(data) data_str = 0x0804a008
(text) main = 0x080491a6
(text) foo = 0x08049196
```



- Notice that in order for variable to be in `.BSS` segment, it has to be __unitialized__ and __declared as a static variable__!
- For reference try removing `static` in front of `bss_int` and see that it becomes part of the stack like all other function variables.
- Also notice in program's output that each subsequent address is lower from the previous, which is expected.

---

#### Sources:

1. https://github.com/hoppersroppers/nightmare/blob/master/modules/00-intro/unit_01.md
2. https://www.geeksforgeeks.org/memory-layout-of-c-program/
