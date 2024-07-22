# Playing with stack&heap in GDB

- First compile `stack.c` with the following:
```sh
$ gcc stack.c -o stack -std=c99 -O0 -g
```

- `-std=c99` means use older C standard, which is needed because `gets` was removed from C.
- `-O0` which disables all compiler optimization, good while debugging.
- `-g` makes symbols readable, allowing GDB to debug it more easily.

## Debugging

- See the addresses of our local variables:

```sh
(gdb) p &x
$2 = (int *) 0x7fffffffde2c
(gdb) p &stackstring
$3 = (char (*)[10]) 0x7fffffffde3e
(gdb) p &heapstring
$4 = (char **) 0x7fffffffde30
```

- Find out where the stack is located at:

```sh
(gdb) p $sp
$6 = (void *) 0x7fffffffde58
```

- Print first 160 bytes (in hex) of a stack:

```sh
(gdb) x /40b $sp
0x7fffffffde58: 0x88    0xdc    0xdc    0xf7    0xff    0x7f    0x00    0x00
0x7fffffffde60: 0xa0    0xde    0xff    0xff    0xff    0x7f    0x00    0x00
0x7fffffffde68: 0x78    0xdf    0xff    0xff    0xff    0x7f    0x00    0x00
0x7fffffffde70: 0x40    0x40    0x55    0x55    0x01    0x00    0x00    0x00
0x7fffffffde78: 0x69    0x51    0x55    0x55    0x55    0x55    0x00    0x00
```

- Set the breakpoint after initializing the local variables and look at the stack again:

```sh
(gdb) x /40b $sp
0x7fffffffde20: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
0x7fffffffde28: 0x00    0x00    0x00    0x00    0x39    0x05    0x00    0x00
0x7fffffffde30: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
0x7fffffffde38: 0xc0    0x6c    0xfe    0xf7    0xff    0x7f    0x68    0x65
0x7fffffffde40: 0x6c    0x6c    0x6f    0x00    0x00    0x00    0x00    0x00
```

- Look at `0x7fffffffde28` it's where variable `x` lives.
- It is set to 1337 (which is 0x539) in hex, notice how it is stored?
- `0x39 0x05`, it's stored this way because of __Little Endian__.
- The computer actually is reading it in reverse which comes up to be the exact value of `x`.

- Now look at `0x7fffffffde38`, notice the bytes: `0x68 0x65 0x6c 0x6c 0x6f`
- Yeah, consulting the ascii table that translates to none other than 'hello'.
- You could've just looked the bytes directly without printing the whole stack with:

```sh
(gdb) x/10x stackstring 
0x7fffffffde3e: 0x68    0x65    0x6c    0x6c    0x6f    0x00    0x00    0x00
0x7fffffffde46: 0x00    0x00
(gdb) x/1s stackstring
0x7fffffffde3e: "hello"
```

- Notice also that `0x7fffffffde30` which is `heapstring` is empty. That's because we haven't reached `malloc` yet.

- By the way remember `disass /m main` will print C along with assembly.
- Breaking just before first `printf`:

```sh
(gdb) b *main+64 # or b stack.c:11
Breakpoint 4 at 0x5555555551a9: file stack.c, line 11.
(gdb) c
Continuing.

Breakpoint 4, main () at stack.c:11
11          printf("Enter stack string: ");
```

- Notice after `malloc` how stack looks like now:
```sh
-- snip--
0x7fffffffde30: 0xa0    0x92    0x55    0x55    0x55    0x55    0x00    0x00
0x7fffffffde38: 0xc0    0x6c    0xfe    0xf7    0xff    0x7f    0x68    0x65
0x7fffffffde40: 0x6c    0x6c    0x6f    0x00    0x00    0x00    0x00    0x00
(gdb) print heapstring
$11 = 0x5555555592a0 ""
```

- We cleary see `heapstring` just points to another memory address, to the heap area.


## Buffer overflow examined in gdb

- Continuing on, giving the input to the program and stopping before first print

```sh
(gdb) b *main+128
Breakpoint 5 at 0x5555555551e9: file stack.c, line 15.
(gdb) c
Continuing.
Enter stack string: abcdefghijklm
Enter malloc string: bananas

Breakpoint 5, main () at stack.c:15
15          printf("Stack string is %s\n", stackstring);
```

- Notice that `heapstring` still points to an address, printing bytes from that address gives:

```sh
(gdb) p heapstring 
$13 = 0x5555555592a0 "bananas"
(gdb) x/10x 0x5555555592a0
0x5555555592a0: 0x62    0x61    0x6e    0x61    0x6e    0x61    0x73    0x00
0x5555555592a8: 0x00    0x00
```

- Let's look at the stack again:

```sh
(gdb) x/50x $sp
0x7fffffffde20: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
0x7fffffffde28: 0x00    0x00    0x00    0x00    0x39    0x05    0x00    0x00
0x7fffffffde30: 0xa0    0x92    0x55    0x55    0x55    0x55    0x00    0x00
0x7fffffffde38: 0xc0    0x6c    0xfe    0xf7    0xff    0x7f    0x61    0x62
0x7fffffffde40: 0x63    0x64    0x65    0x66    0x67    0x68    0x69    0x6a
0x7fffffffde48: 0x6b    0x6c    0x6d    0x00    0x2d    0xef    0x62    0xa4
0x7fffffffde50: 0xf0    0xde
(gdb) x/15x stackstring
0x7fffffffde3e: 0x61    0x62    0x63    0x64    0x65    0x66    0x67    0x68
0x7fffffffde46: 0x69    0x6a    0x6b    0x6c    0x6d    0x00    0x2d
```

- Notice that `stackstring` is supposed to be 10 characters at maximum, but here it's 14.
- This is what's called __stack smashing__ because I overflowed the buffer *intentionally*.
- This could cause __*big*__ problems, from just a program crash to code execution.
- Here it's not that serious, but If we had defined stack before heap in our C program it would overwrite memory address to which points `heapstring`.
- Continuing our program execution:

```sh
(gdb) c
Continuing.
Stack string is abcdefghijklm
Heap string is banans
x is 1337
*** stack smashing detected ***: terminated
Program received signal SIGABRT, Aborted.
```

## Where are the stack and the heap?

- Get the pid of currently ran program from the gdb:
```sh
(gdb) info inferior
  Num  Description       Connection           Executable
* 1    process 6568      4 (native)           /x86_asm/notes/debugging/stack/stack
```

- `/proc/<pid>/maps` is where all memory sections are mapped out for certain `pid`.
- Heap addresses start with `0x5555` and stack addresses start with `0x7fffff`.


---
## To-Do:
1. ~~Write c program in which stack is defined before heap, then overflow the stack.~~
2. Learn more about linux `proc` directory
3. Add another function to `stack.c` set a breakpoint on it and then try to find the stack from main function.
4. Explore stack canary and protection mechanisms https://wiki.osdev.org/Stack_Smashing_Protector


---

Resource: https://jvns.ca/blog/2021/05/17/how-to-look-at-the-stack-in-gdb/
