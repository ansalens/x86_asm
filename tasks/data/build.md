## Building and running

### `print_data.asm`

- Program `print_data.asm` should be compiled and linked as a standalone executable:

```sh
$ nasm -f elf print_data.asm -o bin/print_data.o
$ ld -m elf_i386 bin/print_data.o -o bin/print_data
```

- `LEN equ $ - bytes` gets current position minus `bytes`, that is the length of label `bytes`.
- This time we used __`ESI`__ instead of `EBX` and __`EDI`__ instead of `ECX`, because they are general purpose registers.
- __ESI (Source Index)__ and __EDI (Destination Index)__ are general purpose registers commonly used for string operations such as copying string from `ESI` to `EDI`.


### `types.asm`

- Program `types.asm` demonstrates different data types (sizes) of integers and how moving them around registers works.
- It should be compiled without any error or warning like this:

```sh
$ nasm -f elf types.asm -o bin/types.o
$ gcc ../../call_from_c/caller.c bin/types.o -o bin/types -no-pie -m32
```

- *Notice that large numbers can be typed with underscores to make them more readable*.
- Also `db`, `dw`, `dd` defines data types of 8, 16 and 32 bits respectively.

### `datasection.asm`

- Is program that shows how to define variables in data section.
- Should be compiled like `types.asm` with `-no-pie` flag.

### `ret4bytes.asm`

- First let's get to know all addressing modes in x86 assembly.
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
byte_value db 150
word_value dw 300
add byte_value, 65
mov ax, 45h         ; 0x45 (h means hexadecimal)
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
- Used for accessing data from tables

```asm
byte_table db 14, 9, 43, 23
word_table dw 290, 257, 350, 950

mov cl, byte_table[2]       ; third element
mov cl, byte_table + 2      ; third element
mov cx, word_table[3]       ; fourth element
```

4. Indirect Memory Addressing (IMA)
    - EBX, DI, SI are used for accessing elements from an array.
    - Whenever we use `mov` with different data types, we give it a type specifier, meaning that if we wanted to move a `dword` to EAX we would write: `mov eax, dword 950`
    - In previous example, it's `dword` and not a `word` because EAX is `dword`.

```asm
my_table times 10 dw 0      ; allocates 10 words and initializes them to 0
mov ebx, [my_table]         ; EBX points to first element of an array
mov [ebx], 110              ; moves 110 to the first element of an array
add ebx, 2                  ; adds 2 bytes, meaning next element of an array
mov [ebx], 123
```

- Resource:
https://www.tutorialspoint.com/assembly_programming/assembly_addressing_modes.htm

--- 

- Back to the `ret4bytes.asm`, my program was compiling fine, but every time I ran it I got segfault.
- I managed to find the problem, I was defining `section .data` in the middle of `section .text` and that was causing segfault!
- Text section of code is RO, meaning it can either be defined above or below the `section .data`.
- Also, `rel` keyword before a location in memory doesn't seem to do much, so I've excluded it from the source code.
- Anyway, compile `ret4bytes.asm` as instructed in `types.asm` with `-no-pie` flag to get rid of warnings from `gcc`.
