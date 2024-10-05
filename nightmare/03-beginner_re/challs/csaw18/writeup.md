# A Tour of x86 - writeup

- User gets asked a couple of questions regarding `stage-1.asm`.

## Questions
1. What is the value of dh after line 129 executes? (Answer with a one-byte hex value, prefixed with '0x')
2. What is the value of gs after line 145 executes? (Answer with a one-byte hex value, prefixed with '0x')
3. What is the value of si after line 151 executes? (Answer with a two-byte hex value, prefixed with '0x')
4. What is the value of ax after line 169 executes? (Answer with a two-byte hex value, prefixed with '0x')
5. What is the value of ax after line 199 executes for the first time? (Answer with a two-byte hex value, prefixed with '0x')

## Answers

1. The value of `dh` register is 0x0 after the XOR operation with itself.
2. The value of `ds` segment register is 0x0.
3. The value of `si` source index register is 0x00.
4. The value of `ax` is 0x0e74.
5. The value of `ax` is 0x0e61.
