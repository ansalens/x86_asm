# Overview of buffer overflow mitigations

## Techniques to prevent or mitigate buffer overflow vulnerabilities

- Writing secure code is best way to protect against buffer overflows.
    - This includes not using risky functions.
    - It can be hard to change legacy programs to be more secure.

- Compiler warnings provide good information when your program uses risky functions.

### Stack canaries

- Are random values generated and put on stack.
- These values are checked if they are unchanged just before function returns to the caller.
- If they happen to be changed, `*** stack smashing detected ***` is thrown at you and program terminates.
- These canaries can be leaked by abusing __memory leak__ vulnerabilities (format string vuln).
- Or they can be easily brute forced on 32-bit systems.

### Data execution prevention

- By making the stack non-executable, shell code placed on the stack cant be executed.
- This is called __NX (No Execute)__ in Linux.
- Using `readelf -l` on the program and you can see that NX is implemented:

```sh
  GNU_STACK      0x0000000000000000 0x0000000000000000 0x0000000000000000
                 0x0000000000000000 0x0000000000000000  RW     0x10
```

- This mitigation can be bypassed using __Return Oriented Programming (ROP)__ techniques.

### Address Space Layout Randomization

- ASLR randomizes the base address and other memory areas on each run of the program.
- This makes it harder for the attacker to make ROP chains as it's difficult to predict where things will be.
- If you run `ldd` command on any binary, you will notice that each subsequent run will print different addresses for the base address and each shared library.

## Conclusion

- __All of these mitigations help at creating more secure program, but they are not bullet-proof, as everything can be exploited.__

---

#### Sources

1. https://www.infosecinstitute.com/resources/secure-coding/how-to-mitigate-buffer-overflow-vulnerabilities/
