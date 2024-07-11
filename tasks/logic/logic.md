# Bitwise logical operations in assembly

- For all logical operations in x86 assembly, following is true...
- First operand, op1, can be either register or address in memory.
- Second operand, op2, can be register/address/immediate.

## AND

```asm
and op1, op2
```

- Performs AND bitwise operation, stores result in `op1`.
- Intersection of two sets.
- If you want to zero out upper half of some register:

```asm
; BL is set to 1010 1011
and bl, 0fh ; set BL to 0000 1011
```

- If you need to check if number is odd or even:

```asm
and al, 01h
jz even_number
```

- This works because odd number will always have LSB bit set to 1.
- Now, if the number is even (8 is 1000 e.g.), it won't LSB set.
- Finally if the number is even, `and` instruction will return 0!


## OR

```asm
or op1, op2
```

- Bitwise OR operation, stores result in `op1`.
- Union of two sets.

## NOT

```asm
not op
```

- Bitwise NOT operation, stores the result in `op`.


## XOR

```asm
xor op1, op2
```

- Bitwise XOR operation, stores the result in `op1`.
- Clearing out contents of registers:

```asm
xor eax, eax
```

## TEST

```asm
test op1, op2
```

- Bitwise AND operation just like `and` instruction.
- But it doesn't change the contents of first operand.
- Meaning that the result is temporary.

## Shift and rotate operations

- Logical shift operation (unsigned shift) shifts bits to the left or to the right.
- The bits at the end are discarded except the last one which gets put into __CF__ flag.
- Example: `11001111 -> 011001111` where `1` gets put into __CF__ flag.

```
shr dest, cnt
shl dest, cnt
```

- `shl` shifts left the operand `dest` by `cnt` number of bits.
- Shift left operation performs multiplication 2^N, N being `cnt`.
- That way `shl` with 1, is the same as multiplication with 2.

- `shr` shifts right the operand `dest` by `cnt` number of bits.
- It's the same as dividing the `dest` by 2^N.
- `cnt` can be specified as an immediate or as an register (__CL__ only).

### Arithmetic shift instructions

- Arithmetic shift operation (signed shift) shifts bits to the left or to the right.
- Arithmetic shift is similar to logical shift, except that it will preserve the MSB of a number, keeping it's sign, thus it's called signed shift.

```
sar dest, cnt
sal dest, cnt
```

- `sal` is similar to `shl` instruction.
- Arithmetic shift to the left is same as __signed__ multiplication of `dest` by 2^N, where N is `cnt`.
- `sar` is similar to `shr` instruction, except that it will preserve MSB.
- Arithmetic shift to the right is the same as __signed__ division of `dest` by 2^N.


### Rotate instructions

- Rotate instructions are similar to shift instructions except that bits at the end get transferred at the beginning.

```
ror var, offset
rol var, offset
```

- Consider the following example:
```
mov cl, 10101011b 
ror cl, 1
```

- We get: `11010101`, the `1` at the end was put as MSB.
- This is equivalent to: `offset mod 32`
- `var` can either be a register or a memory location.
- `offset` can be either or immediate value.

- Same applies to `rol` instruction, except that it rotates to the left.

---

#### Sources:

- https://www.tutorialspoint.com/assembly_programming/assembly_logical_instructions.htm
