# gdb-gef

- A lot of this is already covered in `notes/debugging/` and `notes/stack_debug/`.
- Most recent notes are from aviv's [gdb_unit_02/gdb.md](gdb_unit_02/gdb.md).
- Most of these commands and the workflow remain the same just like in vanilla `gdb`, only now it's prettier.


## Changing values

- Notice how this binary is not compiled with debugging symbols included, that means only `nexti` and `stepi` will work.
- Change what is going to be printed with `puts` library function.

```sh
0x0804840f in main ()

[ Legend: Modified register | Code | Heap | Stack | String ]
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$eax   : 0x080483fb  →  <main+0000> lea ecx, [esp+0x4]
$ebx   : 0xf7e2a000  →  0x00229dac
$ecx   : 0xffffd0a0  →  0x00000001
$edx   : 0xffffd0c0  →  0xf7e2a000  →  0x00229dac
$esp   : 0xffffd074  →  0xf7fbe66c  →  0xf7ffdba0  →  0xf7fbe780  →  0xf7ffda40  →  0x00000000
$ebp   : 0xffffd088  →  0xf7ffd020  →  0xf7ffda40  →  0x00000000
$esi   : 0xffffd154  →  0xffffd32d  →  "/home/noobuntu/nightmare/hello_world"
$edi   : 0xf7ffcb80  →  0x00000000
$eip   : 0x0804840f  →  <main+0014> push 0x80484b0
$eflags: [zero carry PARITY ADJUST SIGN trap INTERRUPT direction overflow resume virtualx86 identification]
$cs: 0x23 $ss: 0x2b $ds: 0x2b $es: 0x2b $fs: 0x00 $gs: 0x63 
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0xffffd074│+0x0000: 0xf7fbe66c  →  0xf7ffdba0  →  0xf7fbe780  →  0xf7ffda40  →  0x00000000	 ← $esp
0xffffd078│+0x0004: 0xf7fbeb00  →  0xf7c1acc6  →  "GLIBC_PRIVATE"
0xffffd07c│+0x0008: 0x00000001
0xffffd080│+0x000c: 0x00000001
0xffffd084│+0x0010: 0xffffd0a0  →  0x00000001
0xffffd088│+0x0014: 0xf7ffd020  →  0xf7ffda40  →  0x00000000	 ← $ebp
0xffffd08c│+0x0018: 0xf7c21519  →   add esp, 0x10
0xffffd090│+0x001c: 0xffffd32d  →  "/home/noobuntu/nightmare/hello_world"
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:32 ────
    0x8048408 <main+000d>      push   ecx
    0x8048409 <main+000e>      sub    esp, 0x4
    0x804840c <main+0011>      sub    esp, 0xc
 →  0x804840f <main+0014>      push   0x80484b0
    0x8048414 <main+0019>      call   0x80482d0 <puts@plt>
    0x8048419 <main+001e>      add    esp, 0x10
    0x804841c <main+0021>      mov    eax, 0x0
    0x8048421 <main+0026>      mov    ecx, DWORD PTR [ebp-0x4]
    0x8048424 <main+0029>      leave  
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "hello_world", stopped 0x804840f in main (), reason: SINGLE STEP
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
[#0] 0x804840f → main()
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤  x/s 0x80484b0
0x80484b0:	"hello world!"
gef➤  set {char [12]} 0x80484b0 = "World is yours!"
Too many array elements
gef➤  set {char [12]} 0x80484b0 = "You rock!"
gef➤  x/s 0x80484b0
0x80484b0:	"You rock!"
gef➤  c
Continuing.
You rock!
[Inferior 1 (process 4362) exited normally]
```

- Let's try to change a value stored at `0x80482d0` (puts call).

```sh
gef➤  x/g 0x80482d0
warning: Unable to display strings with size 'g', using 'b' instead.
0x80482d0 <puts@plt>:	"\377%\274\226\004\bh"
gef➤  set *0x80482d0 = 0xfacade
gef➤  x/g 0x80482d0
warning: Unable to display strings with size 'g', using 'b' instead.
0x80482d0 <puts@plt>:	"\336\312", <incomplete sequence \372>
```

- Now jump directly to `0x80482d0`:

```sh
gef➤  j *0x80482d0
Continuing at 0x80482d0.

Program received signal SIGSEGV, Segmentation fault.
```
