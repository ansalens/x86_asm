# pwntools

- pwntools is a python library for rapid exploit developement, used primarily in CTFs.

## Installation

```sh
$ sudo python3 -m pip install --upgrade pip
$ python3 -m pip install --upgrade pwntools
```

## Usage

- Connect to the server:

```py
target = remote("youtube.com", 9999)
```

- Run a target binary:

```py
target = process("./chall")
```

- Attach `gdb` to a process and break at main:

```py
gdb.attach(target, gdbscript='b main')
```

- Send a variable `x` to the target (process or remote connection):

```py
target.send(x)
```

- Send a variable `x` followed by a newline char:

```py
target.sendline(x)
```

- Print a single line of text from `target`:

```py
print target.recvline()
```

- Print all text from `target` up to `'end'`:

```py
print target.recvuntil('end')
```

- Pack the integer `y` as little endian QWORD:

```py
p64(y)
```

- Pack the integer `y` as little endian DWORD:

```py
p32(y)
```

- Unpack a little endian QWORD value:

```py
u64(y)
```

- Or unpack a little endian DWORD value:

```py
u32(y)
```

- Interact directly with the target:

```py
target.interactive()
```

---

#### Sources

1. https://github.com/hoppersroppers/nightmare/blob/master/modules/02-intro_tooling/pwntools/readme.md
2. https://docs.pwntools.com/en/stable/
