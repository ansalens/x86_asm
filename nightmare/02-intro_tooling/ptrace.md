# ptrace (process trace) syscall

- __`ptrace`__ is a syscall that __enables one process to take control of another.__
- It is thanks to `ptrace` that many tools can work.
- These tools include: debuggers, code editors, strace, ltrace...
- Not only in tools, `ptrace` can be used in: sandbox, patching a running program, emulating fake root access...
- When `ptrace` attaches to a process it can change __the process's internal state,registers, memory and send signals.__
- It __allows debugging tools__ to step through the code line by line, place a breakpoint.
- `ptrace` is powerful, and can attach to __any process the current user owns.__

## Limitations

- Because of it's power, it's often deliberately __limited__, one of those limitations is __CAP_SYS_PTRACE__ capability.
- `procfs` allows some processes direct access to program's memory.
- `/proc` is also used for debugging.
- In Linux, processes can call __`prctl`__ syscall to prevent other processes from using `ptrace` on them.
    - `prctl` syscall is used by programs for __setting various limits and control flags on itself.__
    - OpenSSH uses this mechanism to prevent ssh session hijacking.
- Some distros, like Ubuntu use kernel which ships with a feature that prevents processes from attaching to arbitrary process.


---

#### Sources
1. https://en.wikipedia.org/wiki/Ptrace
