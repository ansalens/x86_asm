# `strace` and `ptrace`

- `ptrace` is a syscall that can be used to:
1. trace syscalls
2. examine memory and registers
3. manipulate signal handling

## `ptrace` and syscalls

- __Tracer__ = the program that traces syscalls of other program.
- __Tracee__ = the program that is being traced.


- Tracer uses `PTRACE_ATTACH` flag (when calling `ptrace`) and supplies process ID of a tracee.
- It then calls `ptrace` again but this time with `PTRACE_SYSCALL` flag and PID.
- Tracee runs without stopping until it enters a syscall and is stopped by the kernel.
- For the tracer, the tracee appears to be `SIGTRAP`-ed.
- At this point the tracer can inspect the arguments to a syscall.
- The tracer can call `ptrace` again with `PTRACE_SYSCALL` which resumes the tracee, but gets it stopped again when the syscall is completed.
- Here, the tracer can inspect return values and more stuff.

## `PTRACE_ATTACH`

- It checks for `request` parameter for `PTRACE_ATTACH`.

```c
if (request == PTRACE_ATTACH || request == PTRACE_SEIZE)
  ret = ptrace_attach(child, request, addr, data);
  -- snip --
```

### `ptrace_attach`

- This function ensures couple of things (and more):
1. Ensures that the process that it will attach to is not a kernel thread
2. Ensures that the process that it will attach to is not a thread of a current process
3. Does some security checks

- Flag `PT_PTRACED` is set.



- It check if process is ready for `ptrace` commands with `ptrace_check_attach`.
- It does couple of more things depending on CPU architecture.


## `PTRACE_SYSCALL`

- The syscall begins the same as the `PTRACE_ATTACH` except there is no request attaching.
- It checks if the process is ready for `ptrace` by calling `ptrace_check_attach`.
- Then the architecture dependent stuff is done just like before.
- But for the case `PTRACE_SYSCALL`, `ptrace_resume` is called.

```c
	case PTRACE_SYSCALL:
	case PTRACE_CONT:
		return ptrace_resume(child, request, data);
```

### `ptrace_resume`

- Sets `TIF_SYSCALL_TRACE` flag.
- Tracee is resumed until it enters a syscall.

```c
wake_up_state(child, __TASK_TRACED);
```


## Entering syscalls

- Assembly code depending on architecture is executed whenever a syscall is being made.
- Like the one for x86: https://github.com/torvalds/linux/blob/v3.13/arch/x86/kernel/entry_64.S#L593

## `_TIF_WORK_SYSCALL_ENTRY`

- `_TIF_WORK_SYSCALL_ENTRY` is another flag that is being checked in the previously mentioned assembly.
- If it is set, execution moves to `tracesys`.

```c
#define _TIF_WORK_SYSCALL_ENTRY \
        (_TIF_SYSCALL_TRACE | _TIF_SYSCALL_EMU | _TIF_SYSCALL_AUDIT |   \
         _TIF_SECCOMP | _TIF_SINGLESTEP | _TIF_SYSCALL_TRACEPOINT |     \
         _TIF_NOHZ)
```

- Which is just a collection of other flags, including the familiar `_TIF_SYSCALL_TRACE`
- This is done for every syscall that is called.

## `ptrace_report_syscall`

- This is a function that is responsible for generating `SIGTRAP` for tracee.

```c
ptrace_notify(SIGTRAP | ((ptrace & PT_TRACESYSGOOD) ? 0x80 : 0));
```

### `SIGTRAP`

- This is when tracee gets put to sleep, and the tracer can print registers and other info.
- __This is how `strace` prints each syscall with its arguments__.


### `syscall_trace_leave`

- Now when syscall is finished, the tracee needs to be stopped again when it returns a value.
- Ignoring the function call chain (for brevity), it calls `ptrace_report_syscall` which notifies the tracer.
- As the syscall is completed, the tracer can now display any information regarding the syscall (such as return value).


#### Source

1. https://blog.packagecloud.io/how-does-strace-work/
