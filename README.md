# x86 Assembly

## Context

- These are my notes and sources for x86 assembly. This is my understanding of it.
- Original roadmap is:
    > https://github.com/yds12/x64-roadmap


## Learning goals

- Learn to write x86 assembly.
- Learn to read x86 assembly.
- Learn x86 reverse engineering.
  - Learn binary exploitation.
> https://www.hoppersroppers.org/roadmap/training/pwning.html


## Roadmap

- I will structure my learning plan as follows.
- I will leave a check mark ( ✓ ) when I'm done with the topic.
- At some point in time I will also start studying the following:
> https://github.com/hoppersroppers/nightmare/blob/master/modules/01-intro_assembly/readme.md


### The Basics

* [✓] Install the necessary tools ([`installation/`](tasks/installation))

  * [✓] Install `nasm` ([`nasm.md`](tasks/installation/nasm.md))

  * [✓] Install `ld`, `gcc`, `hexdump`, `objdump` ([`tools`](tasks/installation/utilities.md))

* [✓] First program: the `exit` system call ([`first_prog/`](tasks/first_prog))

  * [✓] Write, assemble and run a program that "does nothing", and check 
  the return value ([`build.md`](tasks/first_prog/build.md))

  * [✓] Try to exit with various exit codes 
  ([`exit8.asm`](tasks/first_prog/exit8.asm) and
  [`exit256.asm`](tasks/first_prog/exit256.asm))

* [✓] Make a [`hello world`](tasks/helloworld/hello.asm) program

* [✓] Call assembly functions from C ([`tasks/calling_from_c/Calling_from_c.md`](tasks/calling_from_c/Calling_from_c.md))

  * [✓] Write an assembly program with a callable function that returns a
  32-bit integer ([`ret_int.asm`](tasks/calling_from_c/ret_int.asm))

  * [✓] Write a small C program that calls this assembly function and displays
  the result in decimal, hexadecimal and binary formats 
  ([`caller.c`](tasks/calling_from_c/caller.c))

  * [✓] Write a program with a function that returns a negative number
  ([`ret_neg.asm`](tasks/calling_from_c/ret_neg_int.asm))

* Registers ([`registers`](tasks/registers))

  * [✓] Register names and sizes ([`x86general.md`](tasks/registers/x86general.md))

  * The `mov` instruction

  * [✓] Write a program that moves values between registers of different sizes
  ([`registers.md`](tasks/registers/registers.md))

  * The `xchg` instruction

* [✓] Look into machine code 
  ([`bin_inspection/howto.md`](tasks/bin_inspection/howto.md))

  * [✓] Check out the machine code of a program with `hexdump`

  * [✓] Disassemble a program with `objdump`

* [✓] Basic Arithmetic ([`arithmetic/arithmetics.md`](tasks/arithmetic/arithmetics.md))

  * [✓] Make a program that sums two numbers 
  ([`add.asm`](tasks/arithmetic/add.asm))

  * [✓] Make a program that subtracts two numbers
  ([`sub.asm`](tasks/arithmetic/sub.asm))
 
  * [✓] Make a program that uses increment
  ([`inc.asm`](tasks/arithmetic/inc.asm))

  * [✓] Make a program that uses decrement
  ([`dec.asm`](tasks/arithmetic/dec.asm))

  * [✓] Make a program that uses unsigned integer multiplication
  ([`mul.asm`](tasks/arithmetic/mul.asm))
 
  * [✓] Make a program that uses signed integer multiplication
  ([`imul.asm`](tasks/arithmetic/imul.asm))

  * [✓] Make a program that obtains the negative of a number
  ([`neg.asm`](tasks/arithmetic/neg.asm))

* [✓] Labels and Unconditional Jumps ([`tasks/jump/unconditional_jumps.md`](tasks/jump/unconditional_jumps.md))

  * [✓] Write a program with a `jmp` instruction
  ([`jump.asm`](tasks/jump/jump.asm) and [`labels.asm`](tasks/jump/labels.asm))

* [✓] Flags, Comparisons and Conditional Jumps 
  ([`tasks/flags/control_flow.md`](tasks/flags/control_flow.md))

  * [✓] Write a program with a conditional jump 
  ([`cond_jump.asm`](tasks/flags/cond_jump.asm))

  * [✓] Write a program with a loop ([`loop.asm`](tasks/flags/loop.asm))

  * [✓] Write a program using the overflow flag
  ([`overflow.asm`](tasks/flags/overflow.asm))

  * [✓] Write a program contrasting the above and below comparisons with the
  greater than and less than comparisons
  ([`above_below.asm`](tasks/flags/above_below.asm))

* [✓] Logical and Bitwise Operations ([`logic/logic.md`](tasks/logic/logic.md))

  * [✓] Use AND and OR ([`and_or.asm`](tasks/logic/and_or.asm))
 
  * [✓] Use NOT and XOR ([`not_xor.asm`](tasks/logic/not_xor.asm))

  * [✓] Shift and Rotate operations ([`shift.asm`](tasks/logic/shift.asm))

* [✓] Data Types, Memory Addressing and the `.data` Section
  ([`data/build.md`](tasks/data/build.md))

  * [✓] How memory works in Linux?
  ([`linux_memory.md`](tasks/data/linux_memory.md))

  * [✓] Write a program that uses the `.data` section
  ([`print_data.asm`](tasks/data/print_data.asm))
 
  * [✓] Write a program that uses different data types
  ([`types.asm`](tasks/data/types.asm))

  * [✓] Write a program that uses addressing with displacement
  ([`ret4bytes.asm`](tasks/data/ret4bytes.asm))

  * [✓] Write a program using addressing with a base register,
  an index register and scale factor
  ([`ret_words.asm`](tasks/data/ret_words.asm))

  * [✓] Write a program using the `.bss` section
  ([`bss.asm`](tasks/data/bss.asm))

  * [✓] Write a program that uses a "global variable" from the `.bss` section
  ([`var_bss.asm`](tasks/data/var_bss.asm))

  * [✓] Write a program that increments a "global variable" from the 
  `.bss` section ([`inc_var.asm`](tasks/data/inc_var.asm))

  * [✓] Write a program that manipulates an array
  ([`array.asm`](tasks/data/array.asm))

* [✓] The Stack ([`stack/stack.md`](tasks/stack/stack.md))

  * [✓] Write a program that uses `push` and `pop`
  ([`push_pop.asm`](tasks/stack/push_pop.asm))

  * [✓] Write a program that uses the stack pointer to allocate space and
  access elements on the stack ([`esp1.asm`](tasks/stack/esp1.asm) and
  [`esp2.asm`](tasks/stack/esp2.asm))

* [✓] The `call` Instruction ([`call/call.md`](tasks/call/call.md))

  * [✓] Write a program that uses `call` ([`call.asm`](tasks/call/call.asm))

  * [✓] Write a program that `call`s a `print` function/subroutine
  ([`print.asm`](tasks/call/print.asm))

* [] Calling External Functions ([`extern/external.md`](tasks/extern/external.md))

  * [✓] Write a program divided in two files using `extern`/`global`
  ([`uselib.asm`](tasks/extern/uselib.asm) and
  [`lib.asm`](tasks/extern/lib.asm))

  * [✓] Write a program divided into two `.asm` files using the `include` macro
  ([`killer.asm`](tasks/extern/killer.asm) and
  [`libkiller.asm`](tasks/extern/libkiller.asm))

  * Write a library with a function containing arguments, and call it from
  another `asm` file

  * [] Call a function from C

  * [] Write an assembly library function that takes arguments, and call it from C

  * [] Write an assembly program that calls a C function

  * [✓] Write an assembly program that calls a C library function
  ([`malloc.asm`](tasks/extern/malloc.asm))

* Using the Heap

  * [] Use C's `malloc` and `free` to allocate and free memory dynamically

* Special `mov` instructions

  * [] Sign and Zero Extend `mov` and "size casting" directive

  * Conditional `mov`

* [✓] Division Arithmetics ([`tasks/arithmetics2/division.md`](tasks/arithmetic2/division.md))

  * [✓] Write a program with `div` instruction
  ([`div.asm`](tasks/arithmetic2/div.asm))
 
  * [✓] Write a program that uses `idiv` instruction to perform signed division
  ([`idiv.asm`](tasks/arithmetic2/idiv.asm))

  * [✓] Write a program that does proper signed division with negative divisor
  ([`idiv2.asm`](tasks/arithmetic2/idiv2.asm))

* [] Manipulating Strings

* [] Floating point arithmetic

* [] NASM local labels

### Challenges

* [] Write a function that receives an integer and prints it

* [] Write a function that receives an integer and returns a string with it

* [] Write a bootloader

* [] Write a function that reverses any string it gets
