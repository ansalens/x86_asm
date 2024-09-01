# ASLR/PIE Intro

- ASLR randomizes starting location of certain memory regions such as the stack, heap and libc.
- It's becoming more common to even randomize starting address of the `main` function.
- *Notice: Running a binary directly in GDB can disable some aspects of ASLR, but attaching GDB to a process can avoid this behaviour.*
    - You can attach GDB to a running program with pwntools.

## ASLR bypass

- One way to bypass ASLR is to somehow __obtain a memory address of target memory region.__
- This can be done with `vmmap` gdb-gef command.

```sh
gef➤  vmmap
[ Legend:  Code | Heap | Stack ]
Start              End                Offset             Perm Path
0x0000555555554000 0x0000555555555000 0x0000000000000000 r-- /home/noobuntu/nightmare/bof/mitigations/demo
0x0000555555555000 0x0000555555556000 0x0000000000001000 r-x /home/noobuntu/nightmare/bof/mitigations/demo
0x0000555555556000 0x0000555555557000 0x0000000000002000 r-- /home/noobuntu/nightmare/bof/mitigations/demo
0x0000555555557000 0x0000555555558000 0x0000000000002000 r-- /home/noobuntu/nightmare/bof/mitigations/demo
0x0000555555558000 0x0000555555559000 0x0000000000003000 rw- /home/noobuntu/nightmare/bof/mitigations/demo
0x00007ffff7c00000 0x00007ffff7c28000 0x0000000000000000 r-- /usr/lib/x86_64-linux-gnu/libc.so.6
0x00007ffff7c28000 0x00007ffff7dbd000 0x0000000000028000 r-x /usr/lib/x86_64-linux-gnu/libc.so.6
0x00007ffff7dbd000 0x00007ffff7e15000 0x00000000001bd000 r-- /usr/lib/x86_64-linux-gnu/libc.so.6
0x00007ffff7e15000 0x00007ffff7e16000 0x0000000000215000 --- /usr/lib/x86_64-linux-gnu/libc.so.6
0x00007ffff7e16000 0x00007ffff7e1a000 0x0000000000215000 r-- /usr/lib/x86_64-linux-gnu/libc.so.6
0x00007ffff7e1a000 0x00007ffff7e1c000 0x0000000000219000 rw- /usr/lib/x86_64-linux-gnu/libc.so.6
0x00007ffff7e1c000 0x00007ffff7e29000 0x0000000000000000 rw-
0x00007ffff7fa8000 0x00007ffff7fab000 0x0000000000000000 rw-
0x00007ffff7fbb000 0x00007ffff7fbd000 0x0000000000000000 rw-
0x00007ffff7fbd000 0x00007ffff7fc1000 0x0000000000000000 r-- [vvar]
0x00007ffff7fc1000 0x00007ffff7fc3000 0x0000000000000000 r-x [vdso]
0x00007ffff7fc3000 0x00007ffff7fc5000 0x0000000000000000 r-- /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
0x00007ffff7fc5000 0x00007ffff7fef000 0x0000000000002000 r-x /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
0x00007ffff7fef000 0x00007ffff7ffa000 0x000000000002c000 r-- /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
0x00007ffff7ffb000 0x00007ffff7ffd000 0x0000000000037000 r-- /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
0x00007ffff7ffd000 0x00007ffff7fff000 0x0000000000039000 rw- /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
0x00007ffffffde000 0x00007ffffffff000 0x0000000000000000 rw- [stack]
0xffffffffff600000 0xffffffffff601000 0x0000000000000000 --x [vsyscall]
```

- On every run of the program, memory addresses of sections will change, but __not their offsets__.
- This means that if you can leak the memory address of the heap you can add the correct offset to obtain the memory address of the stack.
> "We can find this offset in gdb, since the offsets between two memory addresses in the same memory region don't change."

- But that also means that if you manage to leak the address of `libc` you can't obtain the memory address of the `stack` from that, because these two are two different memory regions.

## Position Independent Executable (PIE)

- Is similar security mechanism to that of the ASLR.
- __PIE randomizes binary's code and memory regions.__
- Without PIE, executable has only fixed addresses to worry about.
- With PIE, memory regions and functions are referenced __via an offset value relative to the base address.__
- This base address is randomized on each run of the program.

- Memory regions mentioned from above is meant for these:

```sh
Start              End                Offset             Perm Path
0x0000555555554000 0x0000555555555000 0x0000000000000000 r-- /home/noobuntu/nightmare/bof/mitigations/demo
0x0000555555555000 0x0000555555556000 0x0000000000001000 r-x /home/noobuntu/nightmare/bof/mitigations/demo
0x0000555555556000 0x0000555555557000 0x0000000000002000 r-- /home/noobuntu/nightmare/bof/mitigations/demo
0x0000555555557000 0x0000555555558000 0x0000000000002000 r-- /home/noobuntu/nightmare/bof/mitigations/demo
0x0000555555558000 0x0000555555559000 0x0000000000003000 rw- /home/noobuntu/nightmare/bof/mitigations/demo
```

- As the result of PIE and ASLR combined, here is the first run of a program `demo`:
- *Notice: In order for the addresses to be random, you need to use pwntools to attach to the process, see `attach.py`*

```sh
(remote) gef➤  vmmap
[ Legend:  Code | Heap | Stack ]
Start              End                Offset             Perm Path
0x000056af6cc98000 0x000056af6cc99000 0x0000000000000000 r-- /home/noobuntu/nightmare/bof/mitigations/demo
0x000056af6cc99000 0x000056af6cc9a000 0x0000000000001000 r-x /home/noobuntu/nightmare/bof/mitigations/demo
0x000056af6cc9a000 0x000056af6cc9b000 0x0000000000002000 r-- /home/noobuntu/nightmare/bof/mitigations/demo
0x000056af6cc9b000 0x000056af6cc9c000 0x0000000000002000 r-- /home/noobuntu/nightmare/bof/mitigations/demo
0x000056af6cc9c000 0x000056af6cc9d000 0x0000000000003000 rw- /home/noobuntu/nightmare/bof/mitigations/demo
0x000079f99b400000 0x000079f99b428000 0x0000000000000000 r-- /usr/lib/x86_64-linux-gnu/libc.so.6
0x000079f99b428000 0x000079f99b5bd000 0x0000000000028000 r-x /usr/lib/x86_64-linux-gnu/libc.so.6
0x000079f99b5bd000 0x000079f99b615000 0x00000000001bd000 r-- /usr/lib/x86_64-linux-gnu/libc.so.6
0x000079f99b615000 0x000079f99b616000 0x0000000000215000 --- /usr/lib/x86_64-linux-gnu/libc.so.6
0x000079f99b616000 0x000079f99b61a000 0x0000000000215000 r-- /usr/lib/x86_64-linux-gnu/libc.so.6
0x000079f99b61a000 0x000079f99b61c000 0x0000000000219000 rw- /usr/lib/x86_64-linux-gnu/libc.so.6
0x000079f99b61c000 0x000079f99b629000 0x0000000000000000 rw-
0x000079f99b6d7000 0x000079f99b6da000 0x0000000000000000 rw-
0x000079f99b6ea000 0x000079f99b6ec000 0x0000000000000000 rw-
0x000079f99b6ec000 0x000079f99b6ee000 0x0000000000000000 r-- /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
0x000079f99b6ee000 0x000079f99b718000 0x0000000000002000 r-x /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
0x000079f99b718000 0x000079f99b723000 0x000000000002c000 r-- /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
0x000079f99b724000 0x000079f99b726000 0x0000000000037000 r-- /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
0x000079f99b726000 0x000079f99b728000 0x0000000000039000 rw- /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
0x00007ffeac6d4000 0x00007ffeac6f5000 0x0000000000000000 rw- [stack]
0x00007ffeac7ab000 0x00007ffeac7af000 0x0000000000000000 r-- [vvar]
0x00007ffeac7af000 0x00007ffeac7b1000 0x0000000000000000 r-x [vdso]
0xffffffffff600000 0xffffffffff601000 0x0000000000000000 --x [vsyscall]
```

- And now here's the second run:

```sh
(remote) gef➤  vmmap
[ Legend:  Code | Heap | Stack ]
Start              End                Offset             Perm Path
0x00005a42f8921000 0x00005a42f8922000 0x0000000000000000 r-- /home/noobuntu/nightmare/bof/mitigations/demo
0x00005a42f8922000 0x00005a42f8923000 0x0000000000001000 r-x /home/noobuntu/nightmare/bof/mitigations/demo
0x00005a42f8923000 0x00005a42f8924000 0x0000000000002000 r-- /home/noobuntu/nightmare/bof/mitigations/demo
0x00005a42f8924000 0x00005a42f8925000 0x0000000000002000 r-- /home/noobuntu/nightmare/bof/mitigations/demo
0x00005a42f8925000 0x00005a42f8926000 0x0000000000003000 rw- /home/noobuntu/nightmare/bof/mitigations/demo
0x000077c2f7800000 0x000077c2f7828000 0x0000000000000000 r-- /usr/lib/x86_64-linux-gnu/libc.so.6
0x000077c2f7828000 0x000077c2f79bd000 0x0000000000028000 r-x /usr/lib/x86_64-linux-gnu/libc.so.6
0x000077c2f79bd000 0x000077c2f7a15000 0x00000000001bd000 r-- /usr/lib/x86_64-linux-gnu/libc.so.6
0x000077c2f7a15000 0x000077c2f7a16000 0x0000000000215000 --- /usr/lib/x86_64-linux-gnu/libc.so.6
0x000077c2f7a16000 0x000077c2f7a1a000 0x0000000000215000 r-- /usr/lib/x86_64-linux-gnu/libc.so.6
0x000077c2f7a1a000 0x000077c2f7a1c000 0x0000000000219000 rw- /usr/lib/x86_64-linux-gnu/libc.so.6
0x000077c2f7a1c000 0x000077c2f7a29000 0x0000000000000000 rw-
0x000077c2f7bd2000 0x000077c2f7bd5000 0x0000000000000000 rw-
0x000077c2f7be5000 0x000077c2f7be7000 0x0000000000000000 rw-
0x000077c2f7be7000 0x000077c2f7be9000 0x0000000000000000 r-- /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
0x000077c2f7be9000 0x000077c2f7c13000 0x0000000000002000 r-x /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
0x000077c2f7c13000 0x000077c2f7c1e000 0x000000000002c000 r-- /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
0x000077c2f7c1f000 0x000077c2f7c21000 0x0000000000037000 r-- /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
0x000077c2f7c21000 0x000077c2f7c23000 0x0000000000039000 rw- /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
0x00007ffda1175000 0x00007ffda1196000 0x0000000000000000 rw- [stack]
0x00007ffda11d9000 0x00007ffda11dd000 0x0000000000000000 r-- [vvar]
0x00007ffda11dd000 0x00007ffda11df000 0x0000000000000000 r-x [vdso]
0xffffffffff600000 0xffffffffff601000 0x0000000000000000 --x [vsyscall]
```

- As you compare both outputs, you will see that every region is __randomized!__
- PIE can prevent gdb from making certain breakpoints, but `gdb-gef` offers a solution.

```sh
gef➤  pie b *0x116f
gef➤  pie run
Stopped due to shared library event (no libraries added or removed)

Breakpoint 1, 0x000055555555516f in main ()
[+] base address 0x555555554000
[ Legend: Modified register | Code | Heap | Stack | String ]
───────────────────────────────────────────────────────────────── registers ────
$rax   : 0x00007fffffffdfde  →  0x7fffffffe0d00000
$rbx   : 0x0               
$rcx   : 0x00005555555551a0  →  <__libc_csu_init+0> push r15
$rdx   : 0x00007ffff7fafa00  →  0x00000000fbad2088
$rsp   : 0x00007fffffffdfd0  →  0x00005555555551a0  →  <__libc_csu_init+0> push r15
$rbp   : 0x00007fffffffdff0  →  0x00005555555551a0  →  <__libc_csu_init+0> push r15
$rsi   : 0x9               
$rdi   : 0x00007fffffffdfde  →  0x7fffffffe0d00000
$rip   : 0x000055555555516f  →  <main+42> call 0x555555555040 <fgets@plt>
$r8    : 0x00007ffff7fb1a40  →  0x0000000000000000
$r9    : 0x00007ffff7fb1a40  →  0x0000000000000000
$r10   : 0x7               
$r11   : 0x2               
$r12   : 0x0000555555555060  →  <_start+0> xor ebp, ebp
$r13   : 0x00007fffffffe0d0  →  0x0000000000000001
$r14   : 0x0               
$r15   : 0x0               
$eflags: [ZERO carry PARITY adjust sign trap INTERRUPT direction overflow resume virtualx86 identification]
$cs: 0x0033 $ss: 0x002b $ds: 0x0000 $es: 0x0000 $fs: 0x0000 $gs: 0x0000
───────────────────────────────────────────────────────────────────── stack ────
0x00007fffffffdfd0│+0x0000: 0x00005555555551a0  →  <__libc_csu_init+0> push r15 ← $rsp
0x00007fffffffdfd8│+0x0008: 0x0000555555555060  →  <_start+0> xor ebp, ebp
0x00007fffffffdfe0│+0x0010: 0x00007fffffffe0d0  →  0x0000000000000001
0x00007fffffffdfe8│+0x0018: 0xdb3c67cc21531d00
0x00007fffffffdff0│+0x0020: 0x00005555555551a0  →  <__libc_csu_init+0> push r15 ← $rbp
0x00007fffffffdff8│+0x0028: 0x00007ffff7df1b6b  →  <__libc_start_main+235> mov edi, eax
0x00007fffffffe000│+0x0030: 0x0000000000000000
0x00007fffffffe008│+0x0038: 0x00007fffffffe0d8  →  0x00007fffffffe3f9  →  "/tmp/try"
─────────────────────────────────────────────────────────────── code:x86:64 ────
   0x555555555163 <main+30>        lea    rax, [rbp-0x12]
   0x555555555167 <main+34>        mov    esi, 0x9
   0x55555555516c <main+39>        mov    rdi, rax
 → 0x55555555516f <main+42>        call   0x555555555040 <fgets@plt>
   ↳  0x555555555040 <fgets@plt+0>    jmp    QWORD PTR [rip+0x2f8a]        # 0x555555557fd0 <fgets@got.plt>
      0x555555555046 <fgets@plt+6>    push   0x1
      0x55555555504b <fgets@plt+11>   jmp    0x555555555020
      0x555555555050 <__cxa_finalize@plt+0> jmp    QWORD PTR [rip+0x2fa2]        # 0x555555557ff8
      0x555555555056 <__cxa_finalize@plt+6> xchg   ax, ax
      0x555555555058                  add    BYTE PTR [rax], al
─────────────────────────────────────────────────────── arguments (guessed) ────
fgets@plt (
   $rdi = 0x00007fffffffdfde → 0x7fffffffe0d00000,
   $rsi = 0x0000000000000009,
   $rdx = 0x00007ffff7fafa00 → 0x00000000fbad2088
)
─────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "try", stopped, reason: BREAKPOINT
───────────────────────────────────────────────────────────────────── trace ────
[#0] 0x55555555516f → main()
────────────────────────────────────────────────────────────────────────────────
```


## PIE bypass

- Well it's the same as for the ASLR.
- You need to leak a single memory address from a target memory region, then you figure the rest out by adding the correct offset.


---

#### Sources

1. https://github.com/hoppersroppers/nightmare/blob/master/modules/04-Overflows/5.1-mitigation_aslr_pie/readme.md
