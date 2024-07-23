# `call` instruction and `ret`

```asm
call asm_func
```

- `call` instructions pushes the memory address of an instruction that is right after `call asm_func` instruction.
- Then it jumps to a label that is specified after the `call` keyword.

```asm
ret <N>
```

- `ret` instruction pops caller address from the stack.
- Then it jumps to that address, in other words it jumps back to caller function.
- `N` can be specified as how much bytes to pop (almost always 0).
