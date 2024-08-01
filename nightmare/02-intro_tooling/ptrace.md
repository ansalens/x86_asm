# ptrace (process trace) syscall

- __`ptrace`__ is a syscall that enables one process to take control of another.
- It is thanks to `ptrace` that many tools can work.
- These tools include: debuggers, code editors, strace, ltrace...
- Not only in tools, `ptrace` can be used in: sandbox, patching a running program, emulating fake root access...
- When `ptrace` attaches to a process it can change the process's internal state,registers, memory and send signals.
- It allows debugging tools to step through the code line by line, place a breakpoint.
- `ptrace` is powerful, and can attach to any process the current user owns.

## Limitations

- Because of it's power, it's often deliberately limited, one of those limitations is __CAP_SYS_PTRACE__ capability.
- `procfs` allows some processes direct access to program's memory.
- `/proc` is also used for debugging.
- In Linux, processes can call `prctl` syscall to prevent other processes from using `ptrace` on them.
    - OpenSSH uses this mechanism to prevent ssh session hijacking.
- Some distros, like Ubuntu use kernel which ships with a feature that prevents processes from attaching to arbitrary process.


---

Sources:
1. https://en.wikipedia.org/wiki/Ptrace


