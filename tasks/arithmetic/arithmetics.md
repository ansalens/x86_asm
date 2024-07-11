# Basic arithmetics

- Compiling all these programs is similar as compiling those in `call_from_c`:
```sh
$ nasm -f elf sub.asm -o bin/sub.o 
$ gcc ../call_from_c/caller.c bin/sub.o -o bin/sub -m32
```

- Or it can be done using automated script `caller` like so:
```sh
$ ../../caller sub_negative
$ ./bin/sub_negative 
DEC: 4294967295
HEX: ffffffff
BIN: 11111111 11111111 11111111 11111111
```

- `sub_negative.asm` returns -1 as a result in EAX, but `caller.c` only represents __UNSIGNED__ 32 bit integers.
- *Notice* that in some of these programs (like `add.asm`) we have to initialize the __EAX__ because it holds a random 32-bit value.
- I have yet to figure out why ebx and ecx can't be used to add numbers together.
`mystery.asm`
```asm
section .text
	global asm_func

asm_func:
	mov ebx, -10
	imul eax, ebx, -5
	ret
```

- Trying to run the program:
```sh
$ ../../caller mystery
$ ./bin/mystery 
Segmentation fault (core dumped)
```

- Computer favors the __signed__ multiplication over __unsigned__ multiplication.

__Source (To be read depeer):__
> https://gpfault.net/posts/asm-tut-3.txt.html

## `imul` and `mul` instructions

- `mul` instruction performs __UNSIGNED__ multiplication.
- `mul` takes one operand, the other is assumed to be in one of the following locations:
	1. __AL__ for 8-bit multiplication
	2. __AX__ for 16-bit multiplication
	3. __EAX__ for 32-bit multiplication

- If for e.g. it's 8-bit multiplication then, the result goes into __AL__, and you write `mul ah`.
- This will multiply __AL__ with __AH__ and store it into __AL__, the low 8-bit portion of __EAX__ register.

- `imul` instruction performs __SIGNED__ multiplication.
- `imul` can take one, two or three operands.
- `imul` with one operand is __same as__ `mul` but it performs __SIGNED__ multiplication.
- `imul` with two operands multiplies first with second and stores the result in first.
- `imul` with three operands multiplies two last ones and stores the result in first operand.
	- Third operand has to be an immediate (it has to be number, not a register).
