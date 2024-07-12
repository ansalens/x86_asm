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

### 
