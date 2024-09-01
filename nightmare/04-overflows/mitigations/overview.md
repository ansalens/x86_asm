# Overview of buffer overflow mitigations

## Techniques to prevent or mitigate buffer overflow vulnerabilities

- __Writing secure code is the best way to protect against buffer overflows.__
    - This includes not using risky functions, checking the bounds of an array, compiling with extra options, testing the program with various inputs.
    - But it can also be hard to change legacy programs to be more secure, thus security mechanisms are life savers.

- Compiler warnings provide good information when your program uses risky functions.

### Stack canaries

- Are __random secret values__ generated and put on the stack each and every time the program is ran.
- First byte of stack canary on Linux is always NULL, `0x00`.
- These values are checked if they are modified just before function returns to the caller.
- If they are modified, `*** stack smashing detected ***` is thrown at you and program terminates.
- These canaries can be leaked by abusing __memory leak__ vulnerabilities (format string vulnerability).
- Or they can be easily brute forced on 32-bit systems.

### Data Execution Prevention (DEP)

- By making the stack __non-executable__ (and some other regions of a program), shell code placed on the stack or in global variable __cannot be executed.__
- This is called __NX (No Execute)__ in Linux.
- Using `readelf -l` on the program and you can see that NX is implemented:

```sh
  GNU_STACK      0x0000000000000000 0x0000000000000000 0x0000000000000000
                 0x0000000000000000 0x0000000000000000  RW     0x10
```

- This mitigation can be bypassed using __Return Oriented Programming (ROP)__ techniques.

### Address Space Layout Randomization

- ASLR randomizes the base address and other memory areas on each run of the program.
- Stack, heap and shared libraries are mainly randomized.
- This makes it harder for an attacker to make ROP chains.
- If you run `ldd` command on any binary, you will notice that each subsequent run will print different addresses for the base address and each shared library.

### Relocation Read-Only (RELRO)

- Makes some binary sections read only.

1. __Partial RELRO__

- Is the default for GCC, in attacker's eyes it's almost the same as without partial RELRO.
- The only thing that is different is that __GOT section comes before BSS__, thus preventing overwritting GOT entries.

2. __Full RELRO__

- __All GOT entries are read only__.
- Can be enabled in GCC manually.
- Is much more secure that partial RELRO.
- But increases startup times a lot because all symbols must be resolved before start.

## Conclusion

- __All of these mitigations help at creating more secure program, but they are not bullet-proof, as everything can be exploited.__

---

#### Sources

1. https://www.infosecinstitute.com/resources/secure-coding/how-to-mitigate-buffer-overflow-vulnerabilities/
2. https://ctf101.org/binary-exploitation/relocation-read-only/
