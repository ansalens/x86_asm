# Triage

- Goal is to quickly figure out what the binary is and some basic info about it using CLI commands.

## Methodology

- Depending on what you are analyzing, you will have different methodology.
- If you're analyzing malware, you will look for specific malicious behavior.
- If you're reversing commercial software, your probably need to figure out what needs to be done to bypass license verification.

## Playing with the binary

- Run `file` and `strings` on the binary.
- Run pwntools `checksec` to check for security features in binary.
- Run the program a few times, play with the input, make it small, make it big.
- Then run `ltrace` and `strace` on it.
- When dabbling with massive binaries, good amount of info can be gathered by `ldd` and `readelf`.
- How the heap is used, are there any memory leaks? Use `valgrind`.

## Questions when dabbling with the binary
1. What does the `file` output?
2. Are there any juicy srings?
3. Are there any interesting syscalls being made?
4. Are there any interesting library calls being made?
5. Is there anything else you noticed?

## Dynamic analysis

- Consists of targeted attempts to understand the binary by directly running it.
- `ltrace`, `strace`, `ldd` are all dynamic tools which run the binary.

## Static analysis

- Is analyzing different representations of code (assembly or decompiled C) to gain deeper understanding of the binary without running it.
- Example of a tool which performs static analysis is `ghidra`.
- __Combining the two, both static and dynamic analysis is the best approach.__


---

#### Source

1. https://github.com/hoppersroppers/nightmare/blob/master/modules/03-beginner_re/methodology/triage.md
2. https://github.com/hoppersroppers/nightmare/blob/master/modules/03-beginner_re/methodology/hybrid.md
