# Uncoditional jump and labels

- `jmp` makes an unconditional jump to another point in memory.
- __From the manual__:
> Transfers program control to a different point in the instruction stream without recording return information. The
destination (target) operand specifies the address of the instruction being jumped to. This operand can be an
immediate value, a general-purpose register, or a memory location.

- Label is a way to access the code that lives at the specific address in memory.
- This means that __label is not an instruction__, they are just names for beginning of instructions.
- Labels are useful for jumping to them, changing the execution flow of our program.
- A label can be numeric or symbolic, this is how symbolic labels look like:

```asm
this_is_a_label:
	mov eax, 0
	ret			; must return
```

- Last label __must__ return control to the origin function.
- If entry point __does not__ jump to a label to which it should, then program execution __JUMPS__ to the next label in code.
- *It __keeps jumping__* until it hits first `ret` instruction.

```asm
asm_func:
        mov eax, 120
        ;jmp jump_to_this --- Notice the commented out line

never_executed:
        mov eax, 685

jump_here_now:
        add eax, 15
        ret
```

```shell
$ ./bin/jumpv2 
DEC: 700
HEX: 2bc
BIN: 00000000 00000000 00000010 10111100
```

### Side note

- I have accidently changed `section .text` to `section .global`, which will always produce:

```sh
$ ./bin/jump
Segmentation fault (core dumped)
```
