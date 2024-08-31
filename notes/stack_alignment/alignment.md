# Debugging Stories: Stack alignment matters

## `movaps` instruction

- This instruction moves four single-precision floating points between two XMM registers.
- __General Protection Fault (GPF)__ is thrown at the end user, whenever stack pointer is not 16-byte aligned.
- This GPF looks something like this:

```sh
FAULT HANDLER: user exception (number 13, code 0)
from server.b (ID 0x3),
pc = 0x10112d, sp = 0x229c74, flags = 0x1024
```

- Number 13 identifies that it is GPF, also it is given address of EIP and SP when the program crashed.
- Man page of `gcc` documents this behaviour as follows:

```sh
-mpreferred-stack-boundary=num
Attempt to keep the stack boundary aligned to a 2 raised to num byte boundary.  If -mpreferred-stack-boundary is not specified, the default is 4 (16 bytes or 128 bits)
```

- Good alignment means that `pc` ends with `c` hex character (plus the return address, which makes it 16 byte aligned).

----

#### Sources

1. https://research.csiro.au/tsblog/debugging-stories-stack-alignment-matters/
