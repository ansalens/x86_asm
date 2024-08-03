# Tracing a Program with gdb

- A lot of this is already done in: [fundamentals.md](../../../notes/debugging/fundamentals.md) and in [gdbstack.md](../../../notes/stack_debug/gdbstack.md)
- Compiling with debug symbols (with `-g` flag) makes line by line stepping possible (`step` and `next`).

## Source code line-by-line debugging with `gdb`

- `break` or `b` *<linenum|function|\*address>* - set a breakpoint on line number, function or at the memory address.
- `run` or `r` *\<ARGS\>* - run the program with arguments.
- `continue` or `c` *\<count\>* - continue the program until next breakpoint *count* times.
- `next` or `n` - execute next line and step __over__ the functions.
- `step` or `s` - execute next line and step __into__ the functions.
- `finish` - finish the execution of current function or complete stack frame.
- `print` or `p` - print the value of a variable and store it into *gdb's* variable.
- `list` - display current source code at the location.

## Instruction Level Debugging

- `nexti` or `ni` - move to the next instruction, don't step into function calls.
- `stepi` or `si` - move to the next instruction, step into function calls.
- `disassemble` or `disass` *<frame|function>* - display assembly of a current frame or a given function.
- `info registers` or `i r` - show current values of CPU registers.
- `x` *<address|expression>* - examine the memory at address or an expression.
- `info frame` or `i f` - show info about current stack frame.
- `backtrace` or `bt` - show frames of functions on the stack from the innermost to the outermost.

- Example of `x` command:

```sh
(gdb)  x $esp+0x1c
   0xbffff67c:  add    eax,0x80000000
(gdb) x/s 0x08048513
0x8048513:  "Go Navy! Beat Army!\n"
```

- Example of `p` command:

```sh
(gdb) p/x $eax 
$1 = 0x5
```

- Notice that `x` can be used in many different ways: `x[/Nuf]`
- Where `N` is the number of `u` units to be printed.
- `u` is unit and it can be:
1. `b` - byte
2. `h` - half word
3. `w` - word
4. `g` - giant (quad word)

- and `f` is the format:
1. `i` - instruction
2. `s` - string

- When you step into the function, remember that the top of the stack references return address.

```sh
(gdb) x/wx $esp
0xbffff65c: 0x08048472
(gdb) x/i 0x08048472
   0x8048472 <main+37>: mov    eax,0x0
```

- Right below the `esp` are function arguments:

```sh
(gdb) x/3wx $esp
0xbffff65c: 0x08048472  0x08048513  0x00000005
(gdb) x/s 0x08048513
0x8048513:  "Go Navy! Beat Army!\n"
```

## `backtrace` and `info`

- To see the stack frames:

```sh
(gdb) bt
#0  0x0804843a in print_n_times (str=0x8048513 "Go Navy! Beat Army!\n", n=5) at print_n_times.c:7
#1  0x08048472 in main () at print_n_times.c:18
```

- Where the #0 frame is the current one.
- Or you can get information about the frame this way too:

```sh
(gdb) info frame
Stack level 0, frame at 0xbffff660:
 eip = 0x804843a in print_n_times (print_n_times.c:7); saved eip = 0x8048472
 called by frame at 0xbffff690
 source language c.
 Arglist at 0xbffff658, args: str=0x8048513 "Go Navy! Beat Army!\n", n=5
 Locals at 0xbffff658, Previous frame's sp is 0xbffff660
 Saved registers:
  ebp at 0xbffff658, eip at 0xbffff65c
```

---

Source:
1. https://github.com/hoppersroppers/nightmare/blob/master/modules/02-intro_tooling/gdb-unit_02.md
