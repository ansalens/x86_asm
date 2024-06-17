# Basic arithmetics

- Compiling all these programs is similar as compiling those in `call_from_c`:
```sh
$ nasm -f elf sub.asm -o bin/sub.o 
$ gcc ../call_from_c/caller.c bin/sub.o -o bin/sub -m32
```

- Notice that in `add.asm` we have to initialize the __EAX__ because it holds a random 32-bit value:
- I have yet to figure out why ebx and ecx can't be used to add numbers together.