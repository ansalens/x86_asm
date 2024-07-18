# Debug x86 assembly using GDB

- First to compile a program with extra debugging information for GDB, use `-g` flag:

```sh
$ gdb faulty.c -o faulty -m32 -g
```

- Next to begin debugging in GDB, `gdb ./faulty`
- To run a program (with arguments) as you would normally:

```sh
(gdb) r arg1 arg2
```

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
- Setting a temporary breakpoint:

```sh
(gdb) tb *main
Temporary breakpoint 3 at 0x5655618d: file ../tasks/call_from_c/caller.c, line 7.
```

- You can delete a breakpoint/s in multiple ways:

```sh
(gdb) info breakpoints
Num     Type           Disp Enb Address    What
3       breakpoint     del  y   0x5655618d in main at ../tasks/call_from_c/caller.c:7
4       breakpoint     keep y   0x56556197 in main at ../tasks/call_from_c/caller.c:7
5       breakpoint     keep y   0x565561a1 in main at ../tasks/call_from_c/caller.c:7
(gdb) del 3-4 # deletes breakpoints rannging from 3 to 4
(gdb) del 5   # deletes breakpoint number 5
(gdb) info breakpoints
No breakpoints or watchpoints.
```

- You can enable or disable a certain breakpoint or a range of breakpoints:

```sh
(gdb) disable 1-3   # disables breakpoints ranging from 1 to 3
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

- You can continue program execution until next breakpoint with `(gdb) c`.
- Or you can ignore the breakpoint N number of times (good for loops): `(gdb) c <N>`
- Or you can continue until you encounter a certain line,function,address:
`(gdb) until <line/function/address>`

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
(gdb) info r
(gdb) info shared
```

- To print contents of a variable:
```sh
(gdb) x/i $pc
```

- `x/<N><F><U> memory_address`, where:
1. N is number of times
2. F is a format
    - x for hex
    - d for dec
    - i for instruction....
3. U is unit
    - b for byte
    - h for half word...

- Consider the example:

```sh
(gdb) x/10i $pc
```

- Which prints `10` next instructions (including the current one) from program counter (EIP).
- Or this one:

```sh
(gdb) x/10i 0x56556194
```

- Which prints 10 instructions starting from a memory address.

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

- Show and delete display expressions:

```sh
(gdb) info display
(gdb) delete display <N>
```

---

Sources:
- https://mohit.io/blog/gdb-assembly-language-debugging-101/
- https://mohit.io/blog/gdb-debugging-in-assembly/
- https://www.cse.unsw.edu.au/~learn/debugging/modules/gdb_watch_display/
