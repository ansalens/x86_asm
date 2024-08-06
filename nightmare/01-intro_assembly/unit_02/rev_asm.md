# Unit 2: Reverse Engineering Binary Programs

## Getting at the assembly with `objdump`

- Disassemble the program with:

```sh
$ objdump -M intel -d ./bin/helloworld
```

## Disassembling with `gdb`

- Most important `gdb` command is:

```sh
(gdb) set disassembly-flavor intel
```

- Disassemble functions with `gdb`:

```asm
(gdb) disass printhello
Dump of assembler code for function printhello:
   0x08049166 <+0>:     push   ebp
   0x08049167 <+1>:     mov    ebp,esp
   0x08049169 <+3>:     push   ebx
   0x0804916a <+4>:     sub    esp,0x24
   0x0804916d <+7>:     call   0x80490a0 <__x86.get_pc_thunk.bx>
   0x08049172 <+12>:    add    ebx,0x2e82
```

- Decompile them with:

```asm
(gdb) disass /m printhello
Dump of assembler code for function printhello:
3       void printhello() {
   0x08049166 <+0>:     push   ebp
   0x08049167 <+1>:     mov    ebp,esp
   0x08049169 <+3>:     push   ebx
   0x0804916a <+4>:     sub    esp,0x24
   0x0804916d <+7>:     call   0x80490a0 <__x86.get_pc_thunk.bx>
   0x08049172 <+12>:    add    ebx,0x2e82

4           char hello[15] = "Hello, World!\n";
   0x08049178 <+18>:    mov    DWORD PTR [ebp-0x1b],0x6c6c6548
   0x0804917f <+25>:    mov    DWORD PTR [ebp-0x17],0x57202c6f
   0x08049186 <+32>:    mov    DWORD PTR [ebp-0x14],0x6c726f57
   0x0804918d <+39>:    mov    DWORD PTR [ebp-0x10],0xa2164
```

- You may have noticed, a certain instruction from `main` function:

```asm
 80491c9:       83 e4 f0                and    esp,0xfffffff0
 ```

- It's clear what it's doing but why is it doing?
- Turns out this is aligning `ESP` with the lowest 4 bits due to an old bug in division unit of x86 CPUs.

## x86 the Processor Register State

### x86 Instruction Set

- __MIPS__ is a __RISC (Reduced Instruction Set Computing)__ which makes all the instructions and arguments *always 32 bit in size*.
- __ARM (Acron RISC Machines)__ is also RISC as the name implies.
- x86 on the other hand is __CISC (Complex Instruction Set Computing)__ which means, the sizes of instructions and arguments can vary between 8 bits and 64 bits.
- That is done purposefully for backward compatibility.

### The Base Pointer and Stack Pointer

- `EBP` the base pointer, points to the top of the stack frame (higher address).
- `ESP` the stack pointer, points to the bottom of the stack frame (lower address).
- Function frame looks something like this:

```
           <- 4 bytes ->
          .-------------.    
          |    ...      |    higher address
ebp+0x8 ->| func args   |
ebp+0x4 ->| return addr |       
    ebp ->| saved ebp   |
ebp-0x4 ->|             |
   :      :             :              
   '      '             '
            local args
   .      .             .
   :      :             :
esp+0x4 ->|             |
    esp ->|             |    lower addreses
          '-------------'
```

- The top of function's stack frame contains function arguments.
- The first argument is always at the offset `ebp+0x8`.
- Right below first argument is the return address.
- This is an address of the instruction that will be executed after the called function returns.
- Below that is old `EBP` value, which is used for restoring calling function's stack frame.
- `ESP` is already known and points to the top of the stack, the lowest address occupied by the stack.
- Below `ESP` is unallocated data (which can be easily allocated by subtracting `esp`).

## Stack Frame Management and Assembly

### Stack machines

- x86 CPUs are described as stack machines.
- That's because their execution model is built on the stack data structure.
- Each call to a function pushes that function on the stack and sets up a new stack frame for it.
- Each return from a function destroys the stack frame and pops that function off the stack.

### Allocating a new stack frame

- The following code from `main` function sets up a new stack frame:

```asm
 0x08048426 <+0>:	push   ebp
 0x08048427 <+1>:	mov    ebp,esp
 0x08048429 <+3>:	push   ebx
 0x0804842a <+4>:	sub    esp,0x24
 ```

- This stack frame is tied to `main` function.
- In short it pushes old `ebp` value on the stack, sets `ebp` with `esp` and then it allocates 36 bytes. (`0x24`).
- Once the function returns, `esp` is set to `ebp`, `ebp` gets set with old `ebp` value from the stack, then it performs `leave` instruction by popping `ebp` value and return address. Then it just sets `eip` to return address.
- Visually this is what's happening:

```

    (0) calling         (1) return addr of      (2) push ebp
        function's          calling function   
        stack frame         pushed onto stack

     .-------------.       .-------------.      .-------------.       
     |    ...      |       |    ...      |      |    ...      |  
ebp->|             |  ebp->|             | ebp->|             |
     :             :       :             :      :             :
         calling              calling             calling
     :   stack     :       :   stack     :      :   stack     :
     |   frame     |       |   frame     |      |   frame     |
     |             |       |             |      |             |
esp->|  func args  |       |  func args  |      |  func args  |   
     '-------------'  esp->|  return adr |      |  return adr |
                           '-------------' esp->|  saved ebp  |
                                                '-------------'



       (3) mov ebp,esp         (4) sub esp,0x24

         .-------------.        .-------------.       
         |    ...      |        |    ...      |   
         |             |        |             |  
         :             :        :             :  
            calling                 calling    
         :   stack     :        :   stack     :
         |   frame     |        |   frame     |
         |             |        |             |
         |  func args  |        |  func args  |
         |  retur adr |         |  retur adr  |
esp,ebp->|  saved ebp  |   ebp->|  saved ebp  |
         '-------------'        |             |
                                :             :
                                      New 
                                :   stack     :
                           esp->|      Frame  |
                                '-------------'
```

### The __x86.get_pc_thunk functions

- `main` and `printhello` functions have `__x86.get_pc_thunk.ax` and `__x86.get_pc_thunk.bx` respectively.
- These two functions load the address of the next instruction into lower `AX` and `BX` portions respectively.
- Also after both functions the `add` instruction clears out lower `BH/BL` and `AH/AL` portions of `EBX` and `EAX` registers.
- __These functions handle position independent compilation, but here they have no real purpose.__
- That's because we are compiling our program with `-m32 -no-pie` flags, however `gcc` still adds those functions.
- However, here's how `__x86.get_pc_thunk.bx` works in `printhello`:

```asm
(gdb) x/2i 0x80490a0
   0x80490a0 <__x86.get_pc_thunk.bx>:   mov    ebx,DWORD PTR [esp]
   0x80490a3 <__x86.get_pc_thunk.bx+3>: ret
```

- Because this function is called with `call` instruction, the return address is pushed on top of the stack.
- `mov` instruction sets `ebx` with dereferenced `esp`, that is actually the return address. 
- This instruction at the end of `printhello` is also connected to this:

```asm
mov    ebx,DWORD PTR [ebp-0x4]
```

- It places the return address of the function `printhello` in `ebx`.
- This all works together to enable position independent code, mainly in x86-64.
- Look at the following link for more detailed explanation: 
> https://stackoverflow.com/questions/50105581/how-do-i-get-rid-of-call-x86-get-pc-thunk-ax

### De-allocating a stack frame

- How is the stack frame deallocated and popped of the stack when function finishes?
- Well, two instructions come into play:

```asm
   0x080491c4 <+94>:    leave
   0x080491c5 <+95>:    ret
```

- `leave` instruction does two things in the background:

```asm
mov esp, ebp
pop ebp
```

- First instruction sets `esp` with `ebp`, essentially destroying local scope of a function.
- Second instruction sets `ebp` with an old `ebp` value.
- Visually:

```
                              leave                  leave
                              1. =mov esp,ebp=       2. pop ebp
      .-------------.          .-------------.      .-------------.   
      |    ...      |          |     ...     | ebp->|    ...      |
      |             |          |             |      |             |
      :             :          :             :      :             :
        calling                  calling               calling
      :   stack     :          :  stack      :      :  stack      :
      |   frame     |          |  frame      |      |  frame      |
      |             |          |             |      |
      |  func args  |          |  func args  |      |  func args  |
      |  retur val  |          |  return adr | esp->|  return adr |
 ebp->|  saved ebp  | ebp,esp->| saved ebp   |      '-------------'
      |             |          '-------------'
      :             :
            New 
      :   stack     :
 esp->|      Frame  |
      '-------------'
```

- Stack is almost restored to what it used to be prior to the function call.
- The last thing to do is to pop off the return address and set `eip` to correct instruction.
- This is where `ret` shines, it accomplishes both of these things with:

```asm
pop eip
```
- It pops the return address and sets it into `eip`.
- Visually:

```
                             ret                 
                            1. pop eip          
      .-------------.      .-------------.     
ebp-> |    ...      | ebp->|      ...    |        
      :             :      :             :         
         calling            calling               
      :  stack      :      : stack       :        
      |  frame      |      | frame       |
      |             |      |             |
      |  func args  | esp->| func args   |
esp-> | return adr  |      '-------------'
      '-------------'
```

## Memory References, Jumps/Loops, and Function Calls

### Referencing, De-Referencing, and Setting Memory

- Consider this snippet of C code from `helloworld.c` that initializes char array:

```c
char hello[15] = "Hello, World!\n";
```

- That string will be on the stack, in assembly it looks like this:

```asm
   0x08049178 <+18>:    mov    DWORD PTR [ebp-0x1b],0x6c6c6548
   0x0804917f <+25>:    mov    DWORD PTR [ebp-0x17],0x57202c6f
   0x08049186 <+32>:    mov    DWORD PTR [ebp-0x14],0x6c726f57
   0x0804918d <+39>:    mov    DWORD PTR [ebp-0x10],0xa2164
```

- The source operand in above `mov` instructions is actually ASCII characters stored according to little endian.
- Have a look for yourself:

```python
>>> import codecs
>>> codecs.decode("6c6c6548", "hex")
b'lleH'
```

- `DWORD PTR`, `WORD PTR`, `BYTE PTR` are dereference instructions:

1. `BYTE PTR[addr]`: is a byte pointer, it dereferences one byte at the `addr`
2. `WORD PTR[addr]`: is a word pointer, it dereferences one word at the `addr`
3. `DWORD PTR[addr]`: is a dword pointer, it dereferences one dword at the `addr`

- Something closely similar to these assembly instructions is this ugly C code:

```c
  char hello[15];
  //                      l l e H  
  * ((int *) (hello)) = 0x6c6c6548;      // set hello[0]->hello[3]
  //                          W   , o
  * ((int *) (hello + 4)) = 0x57202c6f; // set hello[4]->hello[7]
  //                          d l r o      
  * ((int *) (hello + 8)) = 0x6c726f57; // set hello[8]->hello[11]
  //                             \n !
  * ((short *) (hello + 12)) = 0xa2164;  // set hello[12]->hello[13]
  //                         \0
  * ((char *) (hello+14)) = 0x00;  // set hello[14]
```

- After initializing char array, comes for loop:

```c
    for (p = hello; *p; p++)
```

- To set up a for loop in assembly we need to initialize our pointer with the start of the char array.
- This is done in two steps:

```asm
   0x08049194 <+46>:    lea    eax,[ebp-0x1b]
   0x08049197 <+49>:    mov    DWORD PTR [ebp-0xc],eax
```

- Notice that the start of our string `hello` is at `ebp-0x1b`.
- First instruction calculates the address that references the beginning of a string (`ebp-0x1b`) and puts it into `eax`.
- Our pointer `p` is at the address `[ebp-0xc]` and it needs to point to the start of the string.
- So it basically dereferences a double word on the address `ebp-0xc` and stores the contents of `eax` inside that address.
- This is done with the second instruction, so it basically does this `p = hello`.

### Loops, Jumps, and Condition Testing

- Here's the for loop in assembly:

```asm
   0x0804845d <+55>:	jmp    0x8048478 <printhello+82>  # ------------.                          
   0x0804845f <+57>:	mov    eax,DWORD PTR [ebp-0xc]    # <------.    |                          
   0x08048462 <+60>:	movzx  eax,BYTE PTR [eax]         #        |    |                          
   0x08048465 <+63>:	movsx  eax,al                     #        |    |                          
   0x08048468 <+66>:	sub    esp,0xc                    #        |    |                          
   0x0804846b <+69>:	push   eax                        #        |    | //exit condition
   0x0804846c <+70>:	call   0x80482f0 <putchar@plt>    #        |    |                          
   0x08048471 <+75>:	add    esp,0x10                   #        |    |                          
   0x08048474 <+78>:	add    DWORD PTR [ebp-0xc],0x1    #        |    |                          
   0x08048478 <+82>:	mov    eax,DWORD PTR [ebp-0xc]    # <------+----'                          
   0x0804847b <+85>:	movzx  eax,BYTE PTR [eax]         #        | //loop body                   
   0x0804847e <+88>:	test   al,al                      #        |                               
   0x08048480 <+90>:	jne    0x804845f <printhello+57>  # -------'
```

- It does a *hard jump* to `0x8048478`, to immediately check for exit condition.

```asm
  0x08048478 <+82>:	mov    eax,DWORD PTR [ebp-0xc]
  0x0804847b <+85>:	movzx  eax,BYTE PTR [eax]
  0x0804847e <+88>:	test   al,al
  0x08048480 <+90>:	jne    0x804845f <printhello+57>
```

- Here it will dereference pointer `p` and store that into `eax` register.
- Since it dereferenced entire `DWORD` into `eax` it needs to check each byte of it, meaning we need to dereference even further.
- It will move one byte from it into `eax`, but `movzx` is a special type of move.
- It moves one byte into lowest portion of `eax` (into `al`) and zeroes out all other portions of that register.
- Technically speaking it will *zero extend* that byte into `eax`.
- So, that means `eax` will store a value similar to `0x0000048` (i.e. 'H') each iteration.
- Next instruction needs to check if that byte is `NULL`, it does this with `test al,al` and changes flag bits accordingly.
- If `al` is zero (in other words, it's a `NULL` byte), then `ZF` flag is set to 1.
    - This is the case when `p` dereferences the end of the string `hello`.
- If `al` is not zero then the jump to `0x804845f` is taken.

- With this, exit condition is checked and execution enters into the body of a loop.


### Function Calls

- This is the body of our loop in assembly:

```asm
   0x0804845f <+57>:	mov    eax,DWORD PTR [ebp-0xc]
   0x08048462 <+60>:	movzx  eax,BYTE PTR [eax]
   0x08048465 <+63>:	movsx  eax,al
   0x08048468 <+66>:	sub    esp,0xc
   0x0804846b <+69>:	push   eax
   0x0804846c <+70>:	call   0x80482f0 <putchar@plt>
   0x08048471 <+75>:	add    esp,0x10
   0x08048474 <+78>:	add    DWORD PTR [ebp-0xc],0x1
```

- Just like before, first two instructions load a single byte from `p` pointer into `eax`.
- Function `putchar` expects a signed integer as it's argument.
- This means that we have to cast our char byte into 4-byte signed integer.
- Next instruction, `movsx` does exactly that. 
- It takes __sign parity bit__ (MSB of first byte) and extends it to other portions so it makes a 4 byte signed integer.
- Next three instructions prepare for a `putchar` function call.
- They subtract the stack pointer so it allocates plenty of space for the arguments and for the function if it needs it.
- Then it pushes the argument stored in `eax`, and finally calls `putchar`.
- The next instruction after the function call, will deallocate the stack for us.
- Final instruction will move our `p` pointer to point to the next character in our `hello` string.
- From there it loops all over again and again until `p` points to the end of the string, to the `NULL` character.


---

#### Source:

1. https://github.com/hoppersroppers/nightmare/blob/master/modules/01-intro_assembly/unit_02.md
