# Debug x86 assembly using GDB

- First to compile a program with extra debugging information for GDB, use `-g` flag:

```sh
$ gdb faulty.c -o faulty -m32 -g
```

- Next to begin debugging in GDB, `gdb ./faulty`

## Disassembling functions

- First set the flavor to Intel, because GAS is ugly.

```sh
(gdb) set disassembly-flavor intel
```

- With `disassemble` you can disassemble functions (decompile) even without running a program:

```sh
(gdb) disass main
Dump of assembler code for function main:
   0x0000118d <+0>:     lea    ecx,[esp+0x4]
   0x00001191 <+4>:     and    esp,0xfffffff0
   0x00001194 <+7>:     push   DWORD PTR [ecx-0x4]
   0x00001197 <+10>:    push   ebp
   0x00001198 <+11>:    mov    ebp,esp
   0x0000119a <+13>:    push   ebx
   0x0000119b <+14>:    push   ecx
   0x0000119c <+15>:    sub    esp,0x10
-- snip --
```

- You can even print C equivalent code (when compiled with `-g`) along with assembly:

```sh
(gdb) disass /m main
-- snip --
8         /* Note that we store result as UNSIGNED integer */
9         uint32_t result = asm_func();
   0x565561aa <+29>:    call   0x56559018
   0x565561af <+34>:    mov    DWORD PTR [ebp-0xc],eax
-- snip --
```

## Breakpoints

- Setting a breakpoint in `gdb` is easy as:

```sh
(gdb) b *0x000011f4
Breakpoint 1 at 0x11f4: file ../tasks/call_from_c/caller.c, line 15
```

- Notice the `*` in front of an address, it's telling the GDB to make a breakpoint at the line stored in that memory address.

- Deleting a breakpoint:

```sh
(gdb) info break
Num     Type           Disp Enb Address    What
1       breakpoint     keep y   0x000011f4
(gdb) del 1
```

- From here we can step one line in the code with `stepi`:

```sh
(gdb) si
```

- Or we can skip over functions we aren't interested `nexti`:
- `finish` is used for stepping out of a function.

```sh
(gdb) ni
(gdb) finish
```

### Data breakpoints

- There is another type of breakpoint called data breakpoint.
- Data breakpoint will halt the program execution whenever value at a memory location __changed.__
- This is crucial in detecting heap overflows.
`watch variable or watch mem_addr`

```sh
(gdb) watch result
Hardware watchpoint 2: result
```

- Another type of `watch` is `rwatch`, which will stop every time a variable or memory location is __read.__
- Can be useful to analyze algorithms and code which is executed.
- And finally, `awatch` breaks the execution of a program if a variable and/or memory location is __read from or written to__.
- These data breakpoints can occur __far too many times__ in a program, that's why it's good to set them late in a code.

## Information

- To view info about registers or about shared libraries:

```sh
(gdb) info registers
(gdb) x/i $pc
(gdb) info shared
```

- View stack trace:

```sh
(gdb) bt
#0  0x56559018 in asm_func ()
#1  0x565561af in main () at ../tasks/call_from_c/caller.c:9
```

## Using `display`

- `display` can be used to display certain information every time we stop through a running program.

```sh
(gdb) display /3i $pc
3: x/3i $pc
=> 0x5655618d <main>:   lea    ecx,[esp+0x4]
   0x56556191 <main+4>: and    esp,0xfffffff0
   0x56556194 <main+7>: push   DWORD PTR [ecx-0x4]
```

- This displays three instructions inside `$pc` program counter on every step/breakpoint.

---

Sources:
- https://mohit.io/blog/gdb-assembly-language-debugging-101/
- https://mohit.io/blog/gdb-debugging-in-assembly/
