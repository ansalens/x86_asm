# Assembly Reversing Problems

## `hello_world`

- `objdump -M intel -D ./bin/hello_world` shows this:

```asm
080483fb <main>:
 80483fb:       8d 4c 24 04             lea    ecx,[esp+0x4]
 80483ff:       83 e4 f0                and    esp,0xfffffff0
 8048402:       ff 71 fc                push   DWORD PTR [ecx-0x4]
 8048405:       55                      push   ebp
 8048406:       89 e5                   mov    ebp,esp
 8048408:       51                      push   ecx
 8048409:       83 ec 04                sub    esp,0x4
 804840c:       83 ec 0c                sub    esp,0xc
 804840f:       68 b0 84 04 08          push   0x80484b0
 8048414:       e8 b7 fe ff ff          call   80482d0 <puts@plt>
 8048419:       83 c4 10                add    esp,0x10
 804841c:       b8 00 00 00 00          mov    eax,0x0
 8048421:       8b 4d fc                mov    ecx,DWORD PTR [ebp-0x4]
 8048424:       c9                      leave
 8048425:       8d 61 fc                lea    esp,[ecx-0x4]
 8048428:       c3                      ret
 8048429:       66 90                   xchg   ax,ax
 804842b:       66 90                   xchg   ax,ax
 804842d:       66 90                   xchg   ax,ax
 804842f:       90                      nop
```

- It apparently does nothing else than printing some text on the screen.
- Here it calls `puts` function.

```asm
 804840f:       68 b0 84 04 08          push   0x80484b0
 8048414:       e8 b7 fe ff ff          call   80482d0 <puts@plt>
```

- Running the program I can see that I was right:

```sh
$ ./bin/hello_world
hello world!
```

## `if_then`

- Output from objdump:

```asm
080483fb <main>:
 80483fb:       8d 4c 24 04             lea    ecx,[esp+0x4]
 80483ff:       83 e4 f0                and    esp,0xfffffff0
 8048402:       ff 71 fc                push   DWORD PTR [ecx-0x4]
 8048405:       55                      push   ebp
 8048406:       89 e5                   mov    ebp,esp
 8048408:       51                      push   ecx
 8048409:       83 ec 14                sub    esp,0x14
 804840c:       c7 45 f4 0a 00 00 00    mov    DWORD PTR [ebp-0xc],0xa
 8048413:       83 7d f4 0a             cmp    DWORD PTR [ebp-0xc],0xa
 8048417:       75 10                   jne    8048429 <main+0x2e>
 8048419:       83 ec 0c                sub    esp,0xc
 804841c:       68 c0 84 04 08          push   0x80484c0
 8048421:       e8 aa fe ff ff          call   80482d0 <puts@plt>
 8048426:       83 c4 10                add    esp,0x10
 8048429:       b8 00 00 00 00          mov    eax,0x0
 804842e:       8b 4d fc                mov    ecx,DWORD PTR [ebp-0x4]
 8048431:       c9                      leave
 8048432:       8d 61 fc                lea    esp,[ecx-0x4]
 8048435:       c3                      ret
```

- It moves `10` into `[ebp-0xc]` then it compares it with `10`:

```asm
 804840c:       c7 45 f4 0a 00 00 00    mov    DWORD PTR [ebp-0xc],0xa
 8048413:       83 7d f4 0a             cmp    DWORD PTR [ebp-0xc],0xa
```

- It doesn't take a jump because `[ebp-0xc]` contains `10`.
- It just continues on to print something on the screen.

```asm
 8048419:       83 ec 0c                sub    esp,0xc
 804841c:       68 c0 84 04 08          push   0x80484c0
 8048421:       e8 aa fe ff ff          call   80482d0 <puts@plt>
 ```
- Then it leaves the function.
- Running the program:

```sh
$ ./bin/if_then
x = ten
```

## `loop`

- I've made some edit to this `objdump` output, and added some comments for clarity:

```asm
080483fb <main>:
 80483fb:	8d 4c 24 04          	lea    ecx,[esp+0x4]
 80483ff:	83 e4 f0             	and    esp,0xfffffff0
 8048402:	ff 71 fc             	push   DWORD PTR [ecx-0x4]
 8048405:	55                   	push   ebp
 8048406:	89 e5                	mov    ebp,esp
 8048408:	51                   	push   ecx
 8048409:	83 ec 14             	sub    esp,0x14
 804840c:	c7 45 f4 00 00 00 00 	mov    DWORD PTR counter,0x0        ; counter = 0
 8048413:	eb 17                	jmp    804842c <main+0x31>
 8048415:	83 ec 08             	sub    esp,0x8                      ; prepare printf call
 8048418:	ff 75 f4             	push   DWORD PTR counter
 804841b:	68 c0 84 04 08       	push   0x80484c0
 8048420:	e8 ab fe ff ff       	call   80482d0 <printf@plt>         ; printf("%d", counter);
 8048425:	83 c4 10             	add    esp,0x10
 8048428:	83 45 f4 01          	add    DWORD PTR counter,0x1        ; counter++;
 804842c:	83 7d f4 13          	cmp    DWORD PTR counter,0x13       ; counter == 19
 8048430:	7e e3                	jle    8048415 <main+0x1a>
 8048432:	b8 00 00 00 00       	mov    eax,0x0
 8048437:	8b 4d fc             	mov    ecx,DWORD PTR [ebp-0x4]
 804843a:	c9                   	leave
 804843b:	8d 61 fc             	lea    esp,[ecx-0x4]
 804843e:	c3                   	ret
 804843f:	90                   	nop
```

- It's basically a for loop that looks something like this in C:

```c
for (int counter = 0; counter <= 19; counter++) {
    printf("%d", counter);
}
```

- And running the program...

```sh
$ ./bin/loop
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
```

---

#### Source

1. https://github.com/hoppersroppers/nightmare/tree/master/modules/01-intro_assembly/reversing_assembly
