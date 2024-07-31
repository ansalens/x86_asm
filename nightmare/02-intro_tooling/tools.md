# Simple Tools and Techniques for Reversing a binary

## Tools

- Hexdump all printable characters:

```sh

$ hexdump -C license_1
00000000  7f 45 4c 46 02 01 01 00  00 00 00 00 00 00 00 00  |.ELF............|
00000010  02 00 3e 00 01 00 00 00  d0 04 40 00 00 00 00 00  |..>.......@.....|
--- snip ---
000006c0  01 00 02 00 43 68 65 63  6b 69 6e 67 20 4c 69 63  |....Checking Lic|
000006d0  65 6e 73 65 3a 20 25 73  0a 00 41 41 41 41 2d 5a  |ense: %s..AAAA-Z|
000006e0  31 30 4e 2d 34 32 2d 4f  4b 00 41 63 63 65 73 73  |10N-42-OK.Access|
000006f0  20 47 72 61 6e 74 65 64  21 00 57 52 4f 4e 47 21  | Granted!.WRONG!|
00000700  00 55 73 61 67 65 3a 20  3c 6b 65 79 3e 00 00 00  |.Usage: <key>...|
--- snip ---
```

- Print all strings that are found in binary:

```sh
$ strings license_1
/lib64/ld-linux-x86-64.so.2
libc.so.6
puts
printf
strcmp
__libc_start_main
__gmon_start__
GLIBC_2.2.5
UH-P
UH-P
[]A\A]A^A_
Checking License: %s
AAAA-Z10N-42-OK
Access Granted!
WRONG!
Usage: <key>
```

- From here we can already solve the challenge by trying `AAAA-Z10N-42-OK` as the license key:

```
$ ./license_1 AAAA-Z10N-42-OK
Checking License: AAAA-Z10N-42-OK
Access Granted!
```

- We can also use `objdump` to print disassembly of a binary:

```asm
$ objdump -d license_1 -M intel

license_1:     file format elf64-x86-64
--- snip ---
00000000004005bd <main>:
  4005bd:       55                      push   rbp
  4005be:       48 89 e5                mov    rbp,rsp
  4005c1:       48 83 ec 10             sub    rsp,0x10
  4005c5:       89 7d fc                mov    DWORD PTR [rbp-0x4],edi
  4005c8:       48 89 75 f0             mov    QWORD PTR [rbp-0x10],rsi
  4005cc:       83 7d fc 02             cmp    DWORD PTR [rbp-0x4],0x2
  4005d0:       75 51                   jne    400623 <main+0x66>
--- snip ---
```

- Right from the beginning it tells us what kind of file it is.
- Print header information with `objdump`:

```sh
$ objdump -x license_1

license_1:     file format elf64-x86-64
license_1
architecture: i386:x86-64, flags 0x00000112:
EXEC_P, HAS_SYMS, D_PAGED
start address 0x00000000004004d0

Program Header:
    PHDR off    0x0000000000000040 vaddr 0x0000000000400040 paddr 0x0000000000400040 align 2**3
         filesz 0x00000000000001f8 memsz 0x00000000000001f8 flags r-x
  INTERP off    0x0000000000000238 vaddr 0x0000000000400238 paddr 0x0000000000400238 align 2**0
         filesz 0x000000000000001c memsz 0x000000000000001c flags r--
    LOAD off    0x0000000000000000 vaddr 0x0000000000400000 paddr 0x0000000000400000 align 2**21
         filesz 0x000000000000083c memsz 0x000000000000083c flags r-x
    LOAD off    0x0000000000000e10 vaddr 0x0000000000600e10 paddr 0x0000000000600e10 align 2**21
         filesz 0x0000000000000240 memsz 0x0000000000000248 flags rw-
 DYNAMIC off    0x0000000000000e28 vaddr 0x0000000000600e28 paddr 0x0000000000600e28 align 2**3
         filesz 0x00000000000001d0 memsz 0x00000000000001d0 flags rw-
    NOTE off    0x0000000000000254 vaddr 0x0000000000400254 paddr 0x0000000000400254 align 2**2
         filesz 0x0000000000000044 memsz 0x0000000000000044 flags r--
EH_FRAME off    0x0000000000000710 vaddr 0x0000000000400710 paddr 0x0000000000400710 align 2**2
         filesz 0x0000000000000034 memsz 0x0000000000000034 flags r--
   STACK off    0x0000000000000000 vaddr 0x0000000000000000 paddr 0x0000000000000000 align 2**4
         filesz 0x0000000000000000 memsz 0x0000000000000000 flags rw-   # notice the stack is not executable!

--- snip ---

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .interp       0000001c  0000000000400238  0000000000400238  00000238  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  1 .note.ABI-tag 00000020  0000000000400254  0000000000400254  00000254  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .note.gnu.build-id 00000024  0000000000400274  0000000000400274  00000274  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .gnu.hash     0000001c  0000000000400298  0000000000400298  00000298  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .dynsym       00000090  00000000004002b8  00000000004002b8  000002b8  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  5 .dynstr       0000004b  0000000000400348  0000000000400348  00000348  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  6 .gnu.version  0000000c  0000000000400394  0000000000400394  00000394  2**1
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  7 .gnu.version_r 00000020  00000000004003a0  00000000004003a0  000003a0  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  8 .rela.dyn     00000018  00000000004003c0  00000000004003c0  000003c0  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  9 .rela.plt     00000078  00000000004003d8  00000000004003d8  000003d8  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
 10 .init         0000001a  0000000000400450  0000000000400450  00000450  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 11 .plt          00000060  0000000000400470  0000000000400470  00000470  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 12 .text         000001e2  00000000004004d0  00000000004004d0  000004d0  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 13 .fini         00000009  00000000004006b4  00000000004006b4  000006b4  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 14 .rodata       0000004e  00000000004006c0  00000000004006c0  000006c0  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
```

- Notice that the `.text` sections starts at `00000000004004d0` and it's length is `000001e2` (482 bytes).
- Now remember that the `main` function starts at `00000000004005bd` which just means that `main` lives in `.text`.
- `.rodata` section is where strings live.

- Realizing that the actual key is stored in one of the registers helps solve this program.
- Solution via `gdb`:

```sh
$ gdb -q ./license_1
Reading symbols from ./license_1...
(No debugging symbols found in ./license_1)
(gdb) b *main
Breakpoint 1 at 0x4005bd
(gdb) disass main
Dump of assembler code for function main:
   0x00000000004005bd <+0>:     push   rbp
   0x00000000004005be <+1>:     mov    rbp,rsp
   0x00000000004005c1 <+4>:     sub    rsp,0x10
   0x00000000004005c5 <+8>:     mov    DWORD PTR [rbp-0x4],edi
   0x00000000004005c8 <+11>:    mov    QWORD PTR [rbp-0x10],rsi
   0x00000000004005cc <+15>:    cmp    DWORD PTR [rbp-0x4],0x2
   0x00000000004005d0 <+19>:    jne    0x400623 <main+102>
   0x00000000004005d2 <+21>:    mov    rax,QWORD PTR [rbp-0x10]
   0x00000000004005d6 <+25>:    add    rax,0x8
   0x00000000004005da <+29>:    mov    rax,QWORD PTR [rax]
   0x00000000004005dd <+32>:    mov    rsi,rax
   0x00000000004005e0 <+35>:    mov    edi,0x4006c4
   0x00000000004005e5 <+40>:    mov    eax,0x0
   0x00000000004005ea <+45>:    call   0x400490 <printf@plt>
   0x00000000004005ef <+50>:    mov    rax,QWORD PTR [rbp-0x10]
   0x00000000004005f3 <+54>:    add    rax,0x8
   0x00000000004005f7 <+58>:    mov    rax,QWORD PTR [rax]
   0x00000000004005fa <+61>:    mov    esi,0x4006da
   0x00000000004005ff <+66>:    mov    rdi,rax
   0x0000000000400602 <+69>:    call   0x4004b0 <strcmp@plt>
   0x0000000000400607 <+74>:    test   eax,eax
   0x0000000000400609 <+76>:    jne    0x400617 <main+90>
   0x000000000040060b <+78>:    mov    edi,0x4006ea
   0x0000000000400610 <+83>:    call   0x400480 <puts@plt>
   0x0000000000400615 <+88>:    jmp    0x40062d <main+112>
   0x0000000000400617 <+90>:    mov    edi,0x4006fa
   0x000000000040061c <+95>:    call   0x400480 <puts@plt>
   0x0000000000400621 <+100>:   jmp    0x40062d <main+112>
   0x0000000000400623 <+102>:   mov    edi,0x400701
   0x0000000000400628 <+107>:   call   0x400480 <puts@plt>
   0x000000000040062d <+112>:   mov    eax,0x0
   0x0000000000400632 <+117>:   leave
   0x0000000000400633 <+118>:   ret
End of assembler dump.
(gdb) b *0x0000000000400602
Breakpoint 2 at 0x400602
(gdb) r KEY
Starting program: license_1 KEY
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".

Breakpoint 1, 0x00000000004005bd in main ()
(gdb) c
Continuing.
Checking License: KEY

Breakpoint 2, 0x0000000000400602 in main ()
(gdb) x/1i $pc
=> 0x400602 <main+69>:  call   0x4004b0 <strcmp@plt>
(gdb) i r
rax            0x7fffffffe26e      140737488347758
rbx            0x7fffffffdeb8      140737488346808
rcx            0x0                 0
rdx            0x0                 0
rsi            0x4006da            4196058
rdi            0x7fffffffe26e      140737488347758
rbp            0x7fffffffdd90      0x7fffffffdd90
rsp            0x7fffffffdd80      0x7fffffffdd80
-- snip --
(gdb) x/s 0x4006da
0x4006da:       "AAAA-Z10N-42-OK"
```

- Trace the systemcalls with `strace` command:

```sh
$ strace ./license_1 KEY_ARG
execve("./license_1", ["./license_1", "KEY_ARG"], 0x7fffa4bb89d8 /* 56 vars */) = 0
--- snip ---
write(1, "Checking License: KEY_ARG\n", 26Checking License: KEY_ARG
) = 26
write(1, "WRONG!\n", 7WRONG!
)                 = 7
exit_group(0)                           = ?
+++ exited with 0 +++
```

- Trace library calls with `ltrace` command:

```sh
$ ltrace ./license_1 KEY >/dev/null
__libc_start_main(0x4005bd, 2, 0x7ffd10c6e408, 0x400640 <unfinished ...>
printf("Checking License: %s\n", "KEY")                                                          = 22
strcmp("KEY", "AAAA-Z10N-42-OK")                                                                 = 10
puts("WRONG!")                                                                                   = 7
+++ exited (status 0) +++
```

## radare2

> "Nobody ever masters radare." - LiveOverflow

```sh
$ r2 license_1
WARN: Relocs has not been applied. Please use `-e bin.relocs.apply=true` or `-e bin.cache=true` next time
[0x004004d0]> aaa
INFO: Analyze all flags starting with sym. and entry0 (aa)
INFO: Analyze imports (af@@@i)
INFO: Analyze entrypoint (af@ entry0)
INFO: Analyze symbols (af@@@s)
INFO: Recovering variables
INFO: Analyze all functions arguments/locals (afva@@@F)
INFO: Analyze function calls (aac)
INFO: Analyze len bytes of instructions for references (aar)
INFO: Finding and parsing C++ vtables (avrr)
INFO: Analyzing methods
INFO: Recovering local variables (afva)
INFO: Type matching analysis for all functions (aaft)
INFO: Propagate noreturn information (aanr)
INFO: Use -AA or aaaa to perform additional experimental analysis
[0x004004d0]> afl
0x00400480    1      6 sym.imp.puts
0x00400490    1      6 sym.imp.printf
0x004004a0    1      6 sym.imp.__libc_start_main
0x004004b0    1      6 sym.imp.strcmp
0x004004d0    1     41 entry0
0x00400500    4     41 sym.deregister_tm_clones
0x00400530    4     57 sym.register_tm_clones
0x00400570    3     28 sym.__do_global_dtors_aux
0x00400590    4     42 sym.frame_dummy
0x004006b0    1      2 sym.__libc_csu_fini
0x004006b4    1      9 sym._fini
0x00400640    4    101 sym.__libc_csu_init
0x004005bd    6    119 main
0x00400450    3     26 sym._init
0x004004c0    1      6 loc.imp.__gmon_start__
[0x004004d0]> s sym.
sym._init                   sym.imp.puts                sym.imp.printf              sym.imp.__libc_start_main
sym.imp.strcmp              sym._start                  sym.deregister_tm_clones    sym.register_tm_clones
sym.__do_global_dtors_aux   sym.frame_dummy             sym.main                    sym.__libc_csu_init
sym.__libc_csu_fini         sym._fini
[0x004004d0]> s sym.main
[0x004005bd]>
```

- `aaa` will automatically analyze functions.
- Getting help about any command is easy:

```sh
[0x004005bd]> aaa?
Usage: aa[a[a[a]]]   # automatically analyze the whole program
| a      show code analysis statistics
| aa     alias for 'af@@ sym.*;af@entry0;afva'
| aaa    perform deeper analysis, most common use
```

- `afl` will print the listing of all the functions available.
- Change the location of `EIP` with `s` command in r2.
- `pdf` will print the disassembly of current function.

```sh
[0x004005bd]> pdf
            ; DATA XREF from entry0 @ 0x4004ed(r)
┌ 119: int main (uint32_t argc, char **argv);
│           ; arg uint32_t argc @ rdi
│           ; arg char **argv @ rsi
│           ; var uint32_t var_4h @ rbp-0x4
│           ; var char **s1 @ rbp-0x10
│           0x004005bd      55             push rbp
│           0x004005be      4889e5         mov rbp, rsp
│           0x004005c1      4883ec10       sub rsp, 0x10
│           0x004005c5      897dfc         mov dword [var_4h], edi     ; argc
│           0x004005c8      488975f0       mov qword [s1], rsi         ; argv
│           0x004005cc      837dfc02       cmp dword [var_4h], 2
│       ┌─< 0x004005d0      7551           jne 0x400623
--- snip ---
```

- Enter *visual mode* with `VV`.
- Select each block of code with `TAB` and `ALT+TAB`.
- ~~Now to move selected block, `SHIFT+HJKL`~~
- Cycle through different representations of disassembly with `P`.
- Remember to seek help with `?`.

### Debugging with r2

- To execute r2 in debugging mode, use `-d` flag, seek to the `main`, analyze all functions and set a breakpoint.

```sh
$ r2 -d license_1
WARN: Relocs has not been applied. Please use `-e bin.relocs.apply=true` or `-e bin.cache=true` next time
[0x7fc87aa33740]> s sym.main
[0x004005bd]> aaa
[0x004005bd]> pdf
            ; DATA XREF from entry0 @ 0x4004ed(r)
┌ 119: int main (int argc, char **argv);
│           ; arg int argc @ rdi
│           ; arg char **argv @ rsi
│           ; var int64_t var_4h @ rbp-0x4
│           ; var int64_t var_10h @ rbp-0x10
│           0x004005bd      55             push rbp
│           0x004005be      4889e5         mov rbp, rsp
│           0x004005c1      4883ec10       sub rsp, 0x10
│           0x004005c5      897dfc         mov dword [var_4h], edi     ; argc
[0x004005bd]> db 0x004005bd
```

- Now go into visual mode again.
- Enter command mode while in visual mode with `:` and run the program with `:> dc`.
- Exit the command mode with an enter.
- Notice the `RIP` in visual mode:

```sh
┌───────────────────────────────────────────┐
│ [0x4005bd]                                │
│   ; DATA XREF from entry0 @ 0x4004ed(r)   │
│ 119: int main (int argc, char **argv);    │
│ ; arg int argc @ rdi                      │
│ ; arg char **argv @ rsi                   │
│ ; var int64_t var_4h @ rbp-0x4            │
│ ; var int64_t var_10h @ rbp-0x10          │
│ main,main,.:  push rbp                    │
│         rip:  mov rbp, rsp                │
│               sub rsp, 0x10               │
│ ; argc                                    │
│               mov dword [var_4h], edi     │
│ ; argv                                    │
│               mov qword [var_10h], rsi    │
│               cmp dword [var_4h], 2       │
│               jne 0x400623                │
└───────────────────────────────────────────┘
```

- Step through instructions line by line with `s` or step out with `S` (doesn't go into functions).

---

#### Source

1. https://www.youtube.com/watch?v=3NTXFUxcKPc
