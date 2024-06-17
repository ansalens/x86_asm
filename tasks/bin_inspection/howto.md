# Binary inspection

Inspecting binaries with standard GNU/Linux tools

## `hexdump`

- This command allows us to see our binary in raw hex format.

```sh
$ hexdump bin/first
-- snip --
0000000 457f 464c 0101 0001 0000 0000 0000 0000
0000010 0002 0003 0001 0000 9000 0804 0034 0000
0000020 10b0 0000 0000 0000 0034 0020 0002 0028
0000030 0005 0004 0001 0000 0000 0000 8000 0804
0000040 8000 0804 0074 0000 0074 0000 0004 0000
0000050 1000 0000 0001 0000 1000 0000 9000 0804
0000060 9000 0804 0009 0000 0009 0000 0005 0000
0000070 1000 0000 0000 0000 0000 0000 0000 0000
0000080 0000 0000 0000 0000 0000 0000 0000 0000
-- snip --
```

- First number is an offset (from the beginning of a file), after that all instructions are in hex format.
- Each char is 4 bits, each group of 4 char is 2 bytes (2 * 8)

## `objdump`

- Generates assembly code from a binary (__decompilation__)
```sh
$ objdump -M intel -D bin/caller1

bin/caller1:     file format elf32-i386

-- snip --
0000118d <main>:
    118d:	8d 4c 24 04          	lea    ecx,[esp+0x4]
    1191:	83 e4 f0             	and    esp,0xfffffff0
    1194:	ff 71 fc             	push   DWORD PTR [ecx-0x4]
    1197:	55                   	push   ebp
    1198:	89 e5                	mov    ebp,esp
    119a:	53                   	push   ebx
    119b:	51                   	push   ecx
    119c:	83 ec 10             	sub    esp,0x10
    119f:	e8 ec fe ff ff       	call   1090 <__x86.get_pc_thunk.bx>
    11a4:	81 c3 50 2e 00 00    	add    ebx,0x2e50
    11aa:	e8 41 01 00 00       	call   12f0 <asm_func>
-- snip --
```

- Notice that some things are just constant in every program

```sh
 8049000:	b8 01 00 00 00       	mov    eax,0x1
```

- So the opcode for `mov` is `b8` in hex
- Because __EAX__ is 32-bit register, there are 4 bytes passed after the `b8` opcode.

## `xxd`

- With `xxd` we make a hexdump of the whole binary, with a nicer format than `hexdump`.
- It will also print all strings found in binary and their offset.

```sh
$ xxd hello
00000000: 7f45 4c46 0101 0100 0000 0000 0000 0000  .ELF............
00000010: 0200 0300 0100 0000 0090 0408 3400 0000  ............4...
00000020: e820 0000 0000 0000 3400 2000 0300 2800  . ......4. ...(.
-- snip --
00002000: 4865 6c6c 6f2c 2077 6f72 6c64 210a 0000  Hello, world!...
-- snip --
```

- ASCII chars are represented with a byte.
- Non-printable characters are shown as a dot.

## Size differences C vs. Assembly

- Assembly compiled binaries are faster and also __smaller__ in size than C compiled binaries.
- To prove that:

```sh
$ du -sh bin/caller1 
16K	bin/caller1
$ du -sh bin/obj1.o 
4.0K	bin/obj1.o
$ du -sh ret_int.asm 
4.0K	ret_int.asm
```

- These are from `tasks/call_from_c` and this output clearly shows that object files or pure assembly files are smaller in size than `gcc` compiled binaries.

```sh
$ objdump -M intel -D bin/obj1.o

bin/obj1.o:     file format elf32-i386


Disassembly of section .text:

00000000 <asm_func>:
   0:	b8 00 94 35 77       	mov    eax,0x77359400
   5:	c3                   	ret
```
