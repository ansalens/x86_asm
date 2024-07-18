# Building and running

## `print_data.asm`

- Program `print_data.asm` should be compiled and linked as a standalone executable:

```sh
$ nasm -f elf print_data.asm -o bin/print_data.o
$ ld -m elf_i386 bin/print_data.o -o bin/print_data
```

- `LEN equ $ -bytes` gets current position minus `bytes`, that is the length of label `bytes`.
- ~~This time we used __`ESI`__ instead of `EBX` and __`EDI`__ instead of `ECX`, because they are general purpose registers.~~
- *In x86 assembly, registers __ESI__ and __EDI__ can't be used instead of __EBX__ and __ECX__ respectively, when making a syscall.*
- __ESI (Source Index)__ and __EDI (Destination Index)__ are general purpose registers commonly used for string operations such as copying string from `ESI` to `EDI`.


## `types.asm`

- Program `types.asm` demonstrates different data types (sizes) of integers and how moving them around registers works.
- It should be compiled without any error or warning like this:

```sh
$ nasm -f elf types.asm -o bin/types.o
$ gcc ../call_from_c/caller.c bin/types.o -o bin/types -no-pie -m32
```

- *Notice that large numbers can be typed with underscores to make them more readable*.
- Also `db`, `dw`, `dd` defines data types of 8, 16 and 32 bits respectively.
- `mov al, [rel one_byte]`, notice `rel` keyword which gets the *relative* address.

### `-no-pie` flag in GCC

- This flag when included, disables generating a PIE __Position Independent Executable__.
- This makes possible for our program to access memory locations without the need to calculate each memory address based on current position.
- In other words, each defined variables, arrays,... are __fixed__ in memory, __ASLR is disabled!__.
- When this flag is excluded, asm program needs to make sure it's accessing right memory location __RELATIVE__ to __instruction pointer__. Because every memory location is randomized every time it's executed.

## `datasection.asm`

- Is program that shows how to define variables in data section.
- Should be compiled like `types.asm` with `-no-pie` flag.

```sh
$ nasm -f elf problem.asm -o bin/problem.o
$ gcc ../call_from_c/caller.c bin/problem.o -o bin/problem -m32
/usr/bin/ld: bin/problem.o: warning: relocation in read-only section `.text'
/usr/bin/ld: warning: creating DT_TEXTREL in a PIE
```

- Q: Why does this code run as expected even with these warnings?
- Q: Why doesn't `mov al, [rel a_byte]` solve a problem?

## `ret4bytes.asm`

- First let's get to know addressing modes in x86 assembly.
- `ret4bytes.asm` will show how to reference values from a memory location with displacement.

---

### Addressing modes

1. Register addressing
    - One or both operands are registers.
    - The other can be a value in memory.
    - Is fastest way of processing data.

```asm
mov dx, username
mov password, cx
mov eax, ebx
```

2. Immediate Addressing
    - First opperand is register or memory location.
    - Second operand is immediate value (constant).

```asm
add byte_value, 65
mov ax, 45h 
```

3. Direct Memory Addressing (DMA)
    - Locating exact start address of a value in memory is done via __DS__ register and an offset.
    - This offset value is called __effective address__.
    - One operand is location in memory the other is a register.

```asm
add byte_value, dl      ; add the register in mem location
mov bx, word_value      ; operand from memory is added to a register
```

#### Direct-offset addressing
- Used for accessing data from arrays.

```asm
byte_array db 14, 9, 43, 23
word_array dw 290, 257, 350, 950

mov cl, byte_array[2]       ; third element
mov cl, byte_array + 2      ; third element
mov cx, word_array[3]       ; fourth element
```

4. Indirect Memory Addressing (IMA)
    - EBX, DI, SI are used for accessing elements from an array.
    - Whenever we use `mov` with different data types, we give it a type specifier, meaning that if we wanted to move a `dword` to EAX we would write: `mov eax, dword 950`
    - In previous example, it's `dword` and not a `word` because EAX is `dword`.

```asm
my_array times 10 dw 0      ; allocates 10 words and initializes them to 0
mov ebx, [my_array]         ; EBX points to first element of an array
mov [ebx], 110              ; moves 110 to the first element of an array
add ebx, 2                  ; adds 2 bytes, meaning next element of an array
mov [ebx], 123
```

- Resource:
https://www.tutorialspoint.com/assembly_programming/assembly_addressing_modes.htm

--- 

- Back to the `ret4bytes.asm`, my program was compiling fine, but every time I ran it I got segfault.
- I managed to find the problem, I was defining `section .data` in the middle of `section .text` and that was causing segfault!
- *.text section of code is RO, meaning it can either be defined above or below the `section .data`.*
- Also, `rel` keyword before a location in memory doesn't seem to do much, so I've excluded it from the source code.
- Anyway, compile `ret4bytes.asm` as instructed in `types.asm` with `-no-pie` flag to get rid of warnings from `gcc`.


## `ret_words.asm`

- First of, `lea` instruction (__Load Effective Address__) loads a pointer, a memory address into a register.
- Secondly, addressing mode which is used in this program is called __scaled indexed addressing mode__ and it's format is:

```asm
[base + index*scale + displacement]
```

- This type of formatting allows the programmer to model 2D arrays.
- Anyway here's what each of those components mean:
1. `base`
    - Value in any general purpose register except ESP.
2. `index`
    - Value in any general purpose register except ESP.
3. `scale`
    - An integral number that can be either 1,2,4 or 8 and is multiplied by index.
4. `displacement`
    - 8, 16, or 32 bit value specifying the displacement in memory.

- Adding all those components up, we get an __effective address__.

--- 

- Despite all my efforts this does not compile safely without `-no-pie`.
- Although it can compile without `-no-pie`, running this executable always produces `SEGFAULT`.

- Q: Why does this program print only binary value and not everything else?
    - Compiling it with `no-pie` somehow disables `printf` function calls in `main` of `caller.c`, how?


## `bss.asm`

- This program deals with BSS section of the memory.
- Here we can use *NASM directives* for reserving memory in BSS section.
- These directives only exist as part of NASM, they are not real instructions.

```asm
.bss
    array: resb 10
```

- This will reserve 10 bytes of memory for an array in BSS section.
- Apart from `resb` there are: `resw` for reserving a word, `resd` for reserving a double word.
- There's also `.rodata` section which stores __Read-Only__ data (constants).

- This program should be compiled as a standalone executable, just like `print_data.asm` program.

- Q: How does this program continue it's execution even when I cross the limit of `int_array` buffer?
    - I kept filling the buffer past its limits (even to 80 chars), but I just can't get it to crash for some reason.

## `var_bss.asm`

- This program shows how to define a global variable in `.bss` section of memory, and how to manipulate it.
- Should be assembled like `print_data.asm`

## `inc_var.asm`

- This program shows increment/decrement instructions on two global variables.
- Assemble it and link it as usual, just like `print_data.asm`.

## `array.asm`

```sh
$ gcc ../call_from_c/caller.c bin/array.o -o bin/array -m32 
/usr/bin/ld: bin/array.o: warning: relocation in read-only section `.text'
/usr/bin/ld: warning: creating DT_TEXTREL in a PIE
```

- Compiling this program as usual spills out the same error I had in `ret_words.asm`.
- Compiling with flag `-no-pie` produces no error, but running the executable prints only binary data.

- I've debug my program with gdb.
- I used `(gdb) watch $eax`, `(gdb) b *asm_func`, `(gdb) i r`, to figure out values inside my `int_array`.
- `int_array` has following values: `0, 2, 4, 6, 8, 10, 12, 14, 16`
- At the end, summing all those values, we get `72` which should be printed at the end.
#### Figure out why does it segfault and fix it!
