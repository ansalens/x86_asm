# Examining stack with GDB pt. 2

- How do I make stack load char array in before heap variable and variable x so that I can overflow the char array to change it's contents?
- Here's what chatgpt told me:
> To overflow stackstring and change the value of heapstring such that it points to a location of your choice, you need to rearrange the variables in such a way that stackstring is allocated before heapstring and x on the stack. Unfortunately, the order of local variable allocation in memory is __determined by the compiler__ and is not something you can control directly through code alone. However, you can use a structure to control the order of variables in memory. 

```sh
(gdb) print &data.x
$6 = (int *) 0x7fffffffddb8
(gdb) print &data.stackstring
$7 = (char (*)[10]) 0x7fffffffdda0
(gdb) print &data.heapstring
$8 = (char **) 0x7fffffffddb0
(gdb) x /40b $sp
0x7fffffffdda0: 0x70    0x75    0x6d    0x70    0x6b    0x69    0x6e    0x00
0x7fffffffdda8: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
0x7fffffffddb0: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
0x7fffffffddb8: 0x64    0x00    0x00    0x00    0xff    0x7f    0x00    0x00
0x7fffffffddc0: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
```

- Now you can see that `stackstring` is allocated before other variables on stack.
- That's because we defined a structure, and with it we define the order of variables on stack.
- I set breakpoint on line 25 and enter the same input as before:

```sh
(gdb) b stackv2.c:25
Breakpoint 4 at 0x555555555204: file stackv2.c, line 25.
(gdb) c
Continuing.
Enter stack string: abcdefghijklm
Enter heap string: bananas

Breakpoint 4, main () at stackv2.c:25
25          printf("String on stack is %s\n", data.stackstring);
```

- Now you can see that I've accomplished almost nothing with the above input:

```sh
(gdb) x /40b $sp
0x7fffffffdda0: 0x61    0x62    0x63    0x64    0x65    0x66    0x67    0x68
0x7fffffffdda8: 0x69    0x6a    0x6b    0x6c    0x6d    0x00    0x00    0x00
0x7fffffffddb0: 0xc0    0x9a    0x55    0x55    0x55    0x55    0x00    0x00
0x7fffffffddb8: 0x64    0x00    0x00    0x00    0xff    0x7f    0x00    0x00
0x7fffffffddc0: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
```

- That is because I've provided not long enough input for `stackstring`.
- You can see `0x7fffffffddb0` (`heapstring`) is unchanged and `0x7fffffffddb8` (`x`) is also unchanged.

- Surprisingly it exited with 0 without segfault.
```sh
(gdb) c
Continuing.
String on stack is abcdefghijklm
String on heap is bananas
x is 100
[Inferior 1 (process 3652) exited normally]
```

## Round 2, overwriting `heapstring` pointer

- Now counting these bytes, we need atleast 17 bytes (17 letters) to begin overwriting memory location of `heapstring`
- Let's change the input we feed into the program:

```sh
(gdb) c
Continuing.
Enter stack string: abcdefghijklmnoABCD
Enter heap string: bananas
```

- Interesting thing happened:

```sh
(gdb) x /40x $sp
0x7fffffffdda0: 0x61    0x62    0x63    0x64    0x65    0x66    0x67    0x68
0x7fffffffdda8: 0x69    0x6a    0x6b    0x6c    0x6d    0x6e    0x6f    0x41
0x7fffffffddb0: 0xc0    0x9a    0x55    0x55    0x55    0x55    0x00    0x00
0x7fffffffddb8: 0x64    0x00    0x00    0x00    0xff    0x7f    0x00    0x00
0x7fffffffddc0: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
```

- How did this not overflow the `heapstring`? It stopped on 'A' and 'BCD' were ignored?
- ChatGPT said that it could be that the compiler is enabling stack protection or that the ASLR is protecting the `heapstring` from overflow.
- I've disabled the stack protection by gcc with: `-fno-stack-protector` but to no avail.

```sh
(gdb) c
Continuing.
String on stack is abcdefghijklmnoAUUUU
String on heap is bananas
x is 100
[Inferior 1 (process 3950) exited normally]
```

## Round 3, overwriting `x` local variable

- Let's try overwriting `x`, 24 bytes are needed to reach it in memory.
- Let's change `x` to 42, make python do that for us:

```python
>>> print('A'*24 + chr(42))
AAAAAAAAAAAAAAAAAAAAAAAA*
```

- Have a look at the stack one more time:

```sh
Enter stack string: AAAAAAAAAAAAAAAAAAAAAAAA*
Enter heap string: random

Breakpoint 1, main () at stackv2.c:25
25          printf("String on stack is %s\n", data.stackstring);
(gdb) x /40b $sp
0x7fffffffdda0: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffdda8: 0x41    0x41    0x41    0x41    0x41    0x41    0x41    0x41
0x7fffffffddb0: 0xc0    0x9a    0x55    0x55    0x55    0x55    0x00    0x00
0x7fffffffddb8: 0x2a    0x00    0x00    0x00    0xff    0x7f    0x00    0x00
0x7fffffffddc0: 0x00    0x00    0x00    0x00    0x00    0x00    0x00    0x00
```

- Notice `0x7fffffffddb8` doesn't have `0x64` anymore, instead `0x2a` which is 42.
- Continue with gdb:

```sh
(gdb) c
Continuing.
String on stack is AAAAAAAAAAAAAAAAUUUU
String on heap is random
x is 42
[Inferior 1 (process 4931) exited normally]
```

--- 

## Post questions

1. How to overflow `stackstring` so `x` contains any number I want it to contain, e.g. 1337?
