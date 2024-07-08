## `reg1.asm`

- This program shows how moving data around registers works.
- At the end, 10 will be in __EBX__ register, and we exit with 10.
```sh
$ nasm -f elf reg1.asm -o bin/object1.o
$ ld -m elf_i386 bin/object1.o -o bin/reg1
$ ./bin/reg1
$ echo $?
10
```

## `reg2.asm`

- This program shows how moving data around from smaller to larger portions of register works.
- From our assembly code we move 70,000 into __EAX__, then move around 7 into different registers before moving it into __AX__ the lower 16 bits of __EAX__.
- I will compile this program with `caller.c` so that I get a nice display of __EAX__

```sh
$ nasm -f elf reg2.asm -o bin/object2.o
$ gcc ../call_from_c/caller.c bin/object2.o -o bin/reg2 -m32
```

- Executing the `reg2` binary:

```sh
$ ./bin/reg2 
DEC: 65543
HEX: 10007
BIN: 00000000 00000001 00000000 00000111
```

- This program's output shows the contents of EAX register.
- When moving a number into lower parts of register, like for our example moving 7 into lower part of 16 bits, it will __ZERO OUT__ those lower 16 bits before moving 7 (111) into it.
- As a reference point, look how `reg2` would execute if we never moved 7 into __AX__:
```sh
$ ./bin/reg2 
DEC: 70000
HEX: 11170
BIN: 00000000 00000001 00010001 01110000
```

- *Something similar to this would happen when in x64 assembly we try to move a value into 32-bit portion of 64 bit registers. It would __erase__ first half of that register (so first 32 bits would be 0) and put a new value in second part of 32 bit portion.*

## `reg3.asm`

- This program is similar to the second, in that it moves 2 billion to __EAX__.
- Then it moves 7 (111) into lower 8 bits of __EAX__, the __AL__ portion of it.
- Compilation is the same as for `reg2.asm`.
```sh
$ ./bin/reg3 
DEC: 2000000007
HEX: 77359407
BIN: 01110111 00110101 10010100 00000111
```

- ~We can see that we have achieved a similar effect to simple addition.~

__NOTICE__ that in this example 2 billion has all 0 bits set in last byte, which means setting any of those bits would achieve simple addition mentioned above.
- But, setting the lower 8 bits using __AL__ portion of __EAX__ register, will have the same behavior as seen above. It will *zero out* that last byte and add the number that was moved into __AL__, as for our case, it was 7 (111).
- Instead it's more easier to look at this example, where we move `1970000123` in __EAX__, but also move 7 into __AL__, which in turn when called from our C program looks like this:

```sh
$ ./bin/reg3 
DEC: 1969999879
HEX: 756bd007
BIN: 01110101 01101011 11010000 00000111
```

- Here the effect is plain simple to see, it zeroed out first byte, before moving 7 (111) into it.
