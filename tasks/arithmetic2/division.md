# Division in x86 assembly

- Division operations generate a __quotient__ and __remainder__.
- All division operations have influence on the flags.
- `div` is used for unsigned division.
- `idiv` is used for signed division.

## Scenario #1

- Divisor is 1 byte.
- Dividend is assumed to be one word and it's stored in `AX`.
- After the division, quotient goes to `AL` and remainder goes to `AH`.

![firstscenario](scrs/first.jpg)


## Scenario #2

- Divisor is 2 bytes.
- Dividend is 4 bytes, and it's stored in DX:AX registers.
- Where 16 most significant bits are stored in DX and 16 least sig. bits are stored in AX.
- Quotient goes to `AX` and remainder goes to `DX`.

![secondscenario](scrs/second.jpg)


### Signed division `idiv` and `cwd`

- If we have negative numbers, we must sign extend the dividend.
- Because of two's complement MSB is a sign value (1 for negative, 0 for positive).
- `cwd` stands for convert word to double word.
- You need to use `cwd` instruction which will sign extend `ax` into `dx:ax`.
- In other words it will copy 1's and fill it into `dx`.

- Note that `idiv2.asm` should be compiled with:

```sh
$ ../../signed_caller idiv2
```
