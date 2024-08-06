# How does ltrace work?

## `ltrace` vs `strace`

- [`strace`](strace.md) is used for tracing syscalls.
- `ltrace` is used for tracing library calls.
    - It can also trace syscall like `strace`.
- Both tools rely on `ptrace` syscall.

## How do programs call functions in libraries?

- Shared library is __loaded into program at random address__ on each run (due to ASLR).
- It's address is unknown until the library is loaded at the __runtime.__
- How is this shared library then used if it's address is unknown?
- Enter __Procedure Linkage Table (PLT)__ and __Global Offset Table (GOT)__.

### PLT and GOT

- GOT contains a list of __absolute addresses.__
- PLT contains group of assembly instructions (called *trampolines*) for each library.
- When library is called, __*trampoline* gets executed.__
- Example of PLT trampoline:

```asm
PLT1: jmp *name1@GOTPCREL(%rip)
      pushq $index1
      jmp .PLT0
```

- It first jumps to an entry stored in GOT.
- These absolute addresses from GOT are initialized to point to `pushq $index1` instruction.
- This instruction gets executed and pushes some value on the stack for dynamic linker.
- The jump instruction jumps to a code that calls dynamic linker.
- Dynamic linker has the task to __figure out which library function is being called using `$index1`.__
- When it locates the target function it overwrites it's __address__ in GOT entry.
- Any subsequent call to the same function executes code at that __address__ instead of invoking dynamic linker.

- `ltrace` inserts itself into this process and places a __software breakpoint__ in the PLT trampoline for specified library function.

## Hardware and software breakpoints

- Hardware breakpoint is a __feature of the CPU__ and is __limited resource.__
- On AMD64 there are __4 registers__ which can hold the address of an instruction at which the program execution needs to stop.
- Software breakpoint __is inserted assembly instruction__, thus it's __unlimited resource.__
- That assembly instruction tends to vary between architectures but on x86 that's `int 0x3`.
- This gets our program to raise interrupt #3, which is used for debugging.
- Kernel delivers `SIGTRAP` signal to the tracer program such as `gdb`.

--- 

- *Side note:*
- Look at the result of executing `breakpoint.asm`:

```sh
$ ./breakpoint
Trace/breakpoint trap (core dumped)
```

- It's crashing, because `SIGTRAP` needs to be handled correctly.
- Software like debuggers handle this signal correctly.



## `ptrace` + `PTRACE_POKETEXT` to modify memory in running programs

- `ptrace` syscall accepts argument `request` that can be set to `PTRACE_POKETEXT`.
- This `PTRACE_POKETEXT` argument allows the tracer to __modify memory of a running program__.
- And that's how `gdb` and other tracer utilities use `ptrace` to insert breakpoints.

## `ptrace` + `PTRACE_POKETEXT` + `int 0x3` = `ltrace`

- This is how `ltrace` works:
1. Attaches to a running program with `ptrace`
2. Locates the PLT in the tracee
3. Uses `ptrace` with `PTRACE_POKETEXT` to insert breakpoints (`int 0x3`) in __PLT trampolines for each library function call.__
4. Resumes execution of tracee

- Then when a program makes a call to a library function:
1. Program executes `int 0x3`
2. Kernel halts the program
3. Kernel notifies `ltrace` for `SIGTRAP` signal
4. `ltrace` __performs further inspection__, to answer which library function call was made, with what arguments, time stamps...

- When `ltrace` finishes with a library function it __must remove `int 0x3` instruction from PLT:__
1. `ltrace` uses `ptrace` with `PTRACE_POKETEXT` to replace `int 0x3` with original code
2. Program resumes execution as expected

---

#### Sources

1. https://blog.packagecloud.io/how-does-ltrace-work/
